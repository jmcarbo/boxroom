# RSS feeds for Boxroom folders
if @authorized
  xml.instruct!
  xml.rss 'version' => '2.0', 'xmlns:dc' => 'http://purl.org/dc/elements/1.1/' do
    xml.channel do
      if @folder
        # RSS header:
        xml.title 'Boxroom folder: ' + h(@folder.name)
        xml.link url_for(:only_path => false, :controller => 'folder', :action => 'list', :id => @folder.id)
        xml.pubDate CGI.rfc1123_date(@folder.date_modified)
        xml.description 'Folder in Boxroom'

        # List the folders:
        @folders.each do |folder|
          xml.item do
            xml.title 'Folder: ' + h(folder.name)
            xml.link url_for(:only_path => false, :controller => 'folder', :action => 'list', :id => folder.id)
            xml.description h(folder.name) + ' is a subfolder of ' + path(folder.parent, true)
            xml.pubDate CGI.rfc1123_date(folder.date_modified)
            xml.guid url_for(:only_path => false, :controller => 'folder', :action => 'list', :id => folder.id)
          end
        end

        # List the files:
        @myfiles.each do |file|
          xml.item do
            xml.title 'File: ' + h(file.filename)
            xml.link url_for(:only_path => false, :controller => 'folder', :action => 'list', :id => file.folder.id)
            xml.description h(file.filename) + ' is a file in ' + path(file.folder, true)
            xml.pubDate CGI.rfc1123_date(file.date_modified)
            xml.guid url_for(:only_path => false, :controller => 'file', :action => 'download', :id => file.id)
          end
        end
      else
        # What to show if the specified folder doesn't exist (anymore)
        # RSS header:
        xml.title 'Boxroom folder: this folder does not exist anymore'
        xml.link url_for(:only_path => false, :controller => 'folder', :action => 'list')
        xml.pubDate CGI.rfc1123_date(Time.now)
        xml.description 'Not existing folder in Boxroom'

        # One item that tells the user to unsubscribe:
        xml.item do
          xml.title 'This folder does not exist (anymore).'
          xml.link url_for(:only_path => false, :controller => 'folder', :action => 'list')
          xml.description 'The Boxroom folder to which you are subscribed does not exist anymore. Please unsubscribe from this feed.'
          xml.pubDate CGI.rfc1123_date(Time.now)
        end
      end
    end
  end
end