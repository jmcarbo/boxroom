class ClipboardController < ApplicationController
  # Put selected item on the clipboard
  def add
    # get the clipboard
    clipboard = find_clipboard

    # add either a folder or a file
    if params[:folder_or_file] == 'folder'
      if folder = Folder.find_by_id(params[:id])
        clipboard.add_folder(folder)
      end
    elsif params[:folder_or_file] == 'file'
      if file = Myfile.find_by_id(params[:id])
        clipboard.add_file(file)
      end
    end

    # show what's on the clipboard
    redirect_to :action => 'show'
  end

  # Copy selected items to current folder
  def copy
    
  end

  # Move selected items to current folder
  def move
    
  end

  # Remove selected item from clipboard
  def remove
    # get the clipboard
    clipboard = find_clipboard

    # add remove either a folder or a file
    if params[:folder_or_file] == 'folder'
      if folder = Folder.find_by_id(params[:id])
        clipboard.remove_folder(folder)
      end
    elsif params[:folder_or_file] == 'file'
      if file = Myfile.find_by_id(params[:id])
        clipboard.remove_file(file)
      end
    end

    # show what's on the clipboard
    redirect_to :action => 'show'
  end

  # Show what's on the clipboard
  def show
    @clipboard = find_clipboard
  end

  # These methods are private:
  # [#find_clipboard] Return the clipboard in session or a new clipboard
  private
    # Return the clipboard in the session or
    # put a new clipboard object in a session and return that.
    def find_clipboard
      return session[:clipboard] ||= Clipboard.new
    end
end