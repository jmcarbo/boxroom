# The folder controller contains the following actions:
# [#index]              the default action, redirects to list
# [#list]               list files and sub folders in a folder
# [#feed]               authorizes, sets appropriate variables and header for RSS feed
# [#feed_warning]       renders page with explanations/warnings about RSS feed
# [#new]                shows the form for creating a new folder
# [#create]             create a new folder
# [#rename]             show the form for adjusting the folder's name
# [#update]             updates the attributes of a folder
# [#destroy]            delete a folder
# [#update_permissions] save the new rights given by the user
class FolderController < ApplicationController
  skip_before_filter :authorize, :only => :feed

  before_filter :does_folder_exist, :except => [:list, :feed, :feed_warning]
  before_filter :authorize_creating, :only => [:new, :create]
  before_filter :authorize_reading, :only => :list
  before_filter :authorize_updating, :only => [:rename, :update, :update_rights]
  before_filter :authorize_deleting, :only => :destroy

  # Sessions are not needed for feeds
  session :off, :only => 'feed'
  layout 'folder', :except => 'feed'

  # The default action, redirects to list.
  def index
    list
    render_action 'list'
  end

  # List the files and sub-folders in a folder.
  def list
    # Get the folder
    @folder = Folder.find_by_id(folder_id)

    # Set if the user is allowed to update or delete in this folder;
    # these instance variables are used in the view.
    @can_update = @logged_in_user.can_update(@folder.id)
    @can_delete = @logged_in_user.can_delete(@folder.id)

    # determine the order in which files are shown
    file_order = 'filename '
    file_order = params[:order_by].sub('name', 'filename') + ' ' if params[:order_by]
    file_order += params[:order] if params[:order]

    # determine the order in which folders are shown
    folder_order = 'name '
    if params[:order_by] and params[:order_by] != 'filesize'    
      folder_order = params[:order_by] + ' '
      folder_order += params[:order] if params[:order]
    end

    # List of subfolders
    @folders = @folder.list_subfolders(@logged_in_user, folder_order.rstrip)

    # List of files in the folder
    @myfiles = @folder.list_files(@logged_in_user, file_order.rstrip)

    #get the correct URL
    url = url_for(:controller => 'folder', :action => 'list', :id => nil)

    # it's nice to have the possibility to go up one level
    @folder_up = '<a href="' + url + '/' + @folder.parent.id.to_s + '">..</a>' if @folder.parent
  end

  # Authorizes, sets the appropriate variables and headers.
  # The feed is actually implemented in: app/views/folder/feed.rxml.
  def feed
    # check for valid access key:
    user = User.find_by_rss_access_key(params[:access_key])
    @authorized = !user.blank?

    # get the folder
    @folder = Folder.find_by_id(folder_id)

    # set appriopriate instance variables,
    # so the feed can be created in folder.rxml
    if @authorized and not @folder.blank?
      if @folder.is_root or user.can_read(@folder.id)
        @folders = @folder.list_subfolders(user, 'name')
        @myfiles = @folder.list_files(user, 'filename')
      else
        @authorized = false
      end
    end

    # finally, set correct header
    if @authorized
      headers['Content-Type'] = 'text/xml'
    else
      headers['Content-Type'] = 'text/html'
    end
  end

  # Page that shows warning about RSS
  # and the feed's authorization.
  def feed_warning
    render
  end

  # Shows the form where a user can enter the name for the a folder.
  # The new folder will be stored in the 'current' folder.
  def new
    @folder = Folder.new
  end

  # Create a new folder with the posted variables from the 'new' view.
  def create
    if request.post?
      @folder = Folder.new(params[:folder])
      @folder.parent_id = folder_id
      @folder.date_modified = Time.now
      @folder.user = @logged_in_user

      if @folder.save
        # copy groups rights on parent folder to new folder
        copy_permissions_to_new_folder(@folder)

        # back to the list
        redirect_to :action => 'list', :id => params[:id]
      else
        render_action 'new'
      end
    end
  end

  # Show a form with the current name of the folder in a text field.
  def rename
    render
  end

  # Update the folder attributes with the posted variables from the 'rename' view.
  def update
    if request.post?
      if @folder.update_attributes(:name => params[:folder][:name], :date_modified => Time.now)
        redirect_to :action => 'list', :id => folder_id
      else
        render_action 'rename'
      end
    end
  end

  # Delete a folder.
  def destroy
    @folder.destroy
    redirect_to :action => 'list', :id => folder_id
  end

  # Saved the new permissions given by the user
  def update_permissions
    if request.post? and @logged_in_user.is_admin?
      # update the create, read, update, delete right for this folder:
      update_group_permissions(folder_id, params[:create_check_box], 'create', params[:update_recursively][:checked] == 'yes' ? true : false)
      update_group_permissions(folder_id, params[:read_check_box], 'read', params[:update_recursively][:checked] == 'yes' ? true : false)
      update_group_permissions(folder_id, params[:update_check_box], 'update', params[:update_recursively][:checked] == 'yes' ? true : false)
      update_group_permissions(folder_id, params[:delete_check_box], 'delete', params[:update_recursively][:checked] == 'yes' ? true : false)
    end

    # Return to the folder
    redirect_to :action => 'list', :id => folder_id
  end

  # These methods are private:
  # [#update_group_permissions]        Update the group folder permissions
  # [#copy_permissions_to_new_folder]  Copy the GroupPermissions of the parent folder to the given folder
  # [#authorize_reading]               Allows/disallows the current user to read the current folder
  # [#authorize_deleting]              Check logged in user's delete permissions for a particular folder
  # [#authorize_deleting_for_children] Check delete permissions for subfolders recursively
  private
    # Update the group permissions for a given group, folder and field.
    # If <i>recursively</i> is true, update the child folders of the given folder too. 
    def update_group_permissions(folder_id_param, group_check_box_list, field, recursively)
      # iteratively update the GroupPermissions
      group_check_box_list.each do |group_id, can_do_it|
        # get the GroupPermissions
        group_permission = GroupPermission.find_by_group_id_and_folder_id(group_id, folder_id_param)

        # Do the actual update if the GroupPermission exists;
        # do not update the permissions of the admins group
        # (it should always be able to do everything)
        unless group_permission.blank? or group_permission.group.is_the_administrators_group?
          case field
          when 'create':
            group_permission.can_create = can_do_it
          when 'read':
            group_permission.can_read = can_do_it
          when 'update':
            group_permission.can_update = can_do_it
          when 'delete':
            group_permission.can_delete = can_do_it
          end
          group_permission.save
        end
      end

      # The recursive part...
      if recursively
        # Update the child folders
        folder = Folder.find_by_id(folder_id_param)
        if folder
          folder.children.each do |child_folder|
            update_group_permissions(child_folder.id, group_check_box_list, field, true)
          end
        end
      end
    end

    # Copy the GroupPermissions of the parent folder to the given folder
    def copy_permissions_to_new_folder(folder)
      # get the 'parent' GroupPermissions
      GroupPermission.find_all_by_folder_id(folder_id).each do |parent_group_permissions|
        # create the new GroupPermissions
        group_permissions = GroupPermission.new
        group_permissions.folder = folder
        group_permissions.group = parent_group_permissions.group
        group_permissions.can_create = parent_group_permissions.can_create
        group_permissions.can_read = parent_group_permissions.can_read
        group_permissions.can_update = parent_group_permissions.can_update
        group_permissions.can_delete = parent_group_permissions.can_delete
        group_permissions.save
      end
    end

    # Redirect to the Root folder and show an error message
    # if current user cannot read in current folder.
    def authorize_reading
      # First check if the folder exists, if it doesn't: show an appropriate message.
      # If the folder does exist, only authorize the read-rights if it's not the Root folder.
      unless Folder.find_by_id(folder_id)
        flash.now[:folder_error] = 'Someone else deleted the folder you are using. Your action was cancelled and you have been taken back to the root folder.'
        redirect_to(:controller => 'folder', :action => 'list', :id => nil) and return false
      else
        super unless folder_id == 1
      end
    end

    # Redirect to the Root folder and show an error message
    # if current user cannot delete in current folder
    def authorize_deleting
      folder = Folder.find_by_id(folder_id)
      unless @logged_in_user.can_delete(folder.id)
        flash.now[:folder_error] = "You don't have delete permissions for this folder."
        redirect_to :controller => 'folder', :action => 'list', :id => folder_id and return false
      else
        authorize_deleting_for_children(folder)
      end
    end

    # Check the delete permissions for all the child folders of the given folder
    def authorize_deleting_for_children(folder)
      folder.children.each do |child_folder|
        unless @logged_in_user.can_delete(child_folder.id)
          error_msg = "Sorry, you don't have delete permissions for one of the subfolders."
          if child_folder.parent.id == folder_id
            flash.now[:folder_error] = error_msg
          else
            flash[:folder_error] = error_msg
          end
          redirect_to :controller => 'folder', :action => 'list', :id => folder_id and return false
        else
          authorize_deleting_for_children(child_folder) # Checks the permissions of a child's children
        end
      end
    end
end