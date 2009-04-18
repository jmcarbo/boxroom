# Helper methods for file views
module FileHelper
  # Replace 'myfile' with 'file' in a message
  def myfile_to_file(msg)
    return msg.sub('myfile', 'file') if msg
  end
end