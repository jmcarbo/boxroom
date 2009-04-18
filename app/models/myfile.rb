require 'zip/zipfilesystem'

# Files in the database are represented by Myfile.
# It's called Myfile, because File is a reserved word.
# Files are in (belong to) a folder and are uploaded by (belong to) a User.
class Myfile < ActiveRecord::Base
  acts_as_ferret :store_class_name => true, :fields => { :text => { :store => :yes }, :filename => { :store => :no } }

  belongs_to :folder
  belongs_to :user

  has_many :usages, :dependent => :destroy

  validates_uniqueness_of :filename, :scope => 'folder_id'

  # Validate if the user's data is valid.
  def validate
    if self.filename.blank?
      errors.add(:filename, " can't blank.")
    end
  end

  # Accessor that receives the data from the form in the view.
  # The file will be saved in a folder called 'uploads'.
  # (See: AWDWR pp. 362.)
  def myfile=(myfile_field)
    if myfile_field and myfile_field.length > 0
      # Get the filename
      filename = Myfile.base_part_of(myfile_field.original_filename)

      # Set date_time_created,
      # this will be the files temporary name.
      # (this instance variable is also used in temp_path)
      @date_time_created = Time.now.to_f

      # Save the file on the file system
      File.open(self.temp_path, 'wb') do |f|
        while buff = myfile_field.read(4096)
          f.write(buff)
        end
      end

      # Variable to hold the plain text content of the uploaded file
      text_in_file = nil

      # Try to get the text from the uploaded file
      case filename
        when /.txt$/
          text_in_file = File.open(self.temp_path) { |f| f.read }

        when /.htm$|.html$/ # get the file, strip all <> tags
          text_in_file = File.open(self.temp_path) { |f| f.read.gsub(/<head>.*?<\/head>/m,'').gsub(/<.*?>/, ' ') }

        when /.sxw$|.odt$/ # read content.xml from zip file, strip <> tags
          Zip::ZipFile.open(self.temp_path) do |zipfile|
            text_in_file = zipfile.file.open('content.xml') { |f| f.read.gsub(/<.*?>/, ' ') }
          end
      end

      # If it didn't get caught yet, try the helpers
      if text_in_file.blank?
        INDEX_HELPERS.each do |index_helper| # defined in environment.rb
          if filename =~ index_helper[:ext] # a matching helper!   

            if index_helper[:file_output] # a file that writes to an output file
              `#{ sprintf(index_helper[:helper], self.temp_path, self.temp_path + '_copy') }`
              text_in_file = File.open(self.temp_path + '_copy') { |f| f.read }
              File.delete(self.temp_path + '_copy')
            else # we get the contents from stido directly
              text_in_file = `#{ sprintf(index_helper[:helper], self.temp_path) }`
            end

            # Check if we need to remove first part (e.g. unrtf)
            unless index_helper[:remove_before].blank?
              if index_helper[:remove_before].match(text_in_file)
                text_in_file = Regexp::last_match.post_match 
              end
            end

            # Check if we need to remove last part
            unless index_helper[:remove_after].blank?
              if index_helper[:remove_after].match(text_in_file)
                text_in_file = Regexp::last_match.pre_match
              end
            end
          end
        end
      end

      unless text_in_file.blank?
        self.text = text_in_file.strip # assign text_in_file to self.text to get it indexed
        self.indexed = true
      end

      # Save it all to the database
      self.filename = filename
      filesize = (myfile_field.length / 1000).to_i
      if filesize == 0
        self.filesize = 1 # a file of 0 KB doesn't make sense
      else
        self.filesize = filesize
      end
    end
  end

  attr_writer :text # Setter for text

  # Getter for text.
  # If text is blank get the text from the index.
  def text
    @text = Myfile.ferret_index[self.document_number][:text] if @text.blank?
  end

  after_create :rename_newfile
  # The file in the uploads folder has the same name as the id of the file.
  # This must be done after_create, because the id won't be available any earlier.
  def rename_newfile
    File.rename self.temp_path, self.path
  end

  before_destroy :delete_file_on_disk
  # When removing a myfile record from the database,
  # the actual file on disk has to be removed too.
  # That is exactly what this method does.
  def delete_file_on_disk
    File.delete self.path
  end

  # Strip of the path and replace all the non alphanumeric,
  # underscores and periods in the filename with an underscore.
  def self.base_part_of(file_name)
    # NOTE: File.basename doesn't work right with Windows paths on Unix
    # INCORRECT: just_filename = File.basename(file_name.gsub('\\\\', '/')) 
    # get only the filename, not the whole path
    name = file_name.gsub(/^.*(\\|\/)/, '')

    # finally, replace all non alphanumeric, underscore or periods with underscore
    name.gsub(/[^\w\.\-]/, '_') 
  end

  # Returns the location of the file before it's saved
  def temp_path
    "#{UPLOAD_PATH}/#{@date_time_created}"
  end

  # The path of the file
  def path
    "#{UPLOAD_PATH}/#{self.id}"
  end
end