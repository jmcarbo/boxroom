# Files and folders can be stored temporary on the clipboard.
# Objects are not persisted to the database as the nature of a clipboard object
# is that it's temporary.
class Clipboard
  attr_reader :folders
  attr_reader :files

  # Initialize clipboard object.
  # We're starting with an empty clipboard:
  # the @folders and @files arrays are empty too.
  def initialize
    @folders = []
    @files = []
  end

  # Put given folder on clipboard
  # unless it's already there
  def add_folder(folder)
    @folders << folder unless @folders.find{ |f| f.id == folder.id }
  end

  # Put given file on clipboard
  # unless it's already there
  def add_file(file)
    @files << file unless @files.find{ |f| f.id == file.id }
  end

  # Remove given folder from clipboard
  def remove_folder(folder)
    @folders.delete(folder)
  end

  # Remove given file from clipboard
  def remove_file(file)
    @files.delete(file)
  end
end