# The group controller contains the following actions:
# [#index]   the default action, redirects to list
# [#list]    list all the groups
# [#new]     shows the form for creating a new group
# [#create]  create a new group
# [#rename]  show the form for adjusting the name of a group
# [#update]  updates the attributes of a group
# [#destroy] delete a group
class GroupController < ApplicationController
  before_filter :authorize_admin # this should only be accessible for admins
  before_filter :does_group_exist, :only => [:rename, :update, :destroy] # if the group DOES exist, @group is set to it
  before_filter :do_not_rename_or_destroy_admins_group, :only => [:rename, :destroy]

  # The default action, redirects to list.
  def index
    list
    render :action => 'list'
  end

  # List all the groups.
  def list
    @groups = Group.find(:all, :order => 'name')
  end

  # Show a form to enter data for a new group.
  def new
    @group = Group.new
  end

  # Create a new group using the posted data from the 'new' view.
  def create
    if request.post?
      @group = Group.new(params[:group])

      if @group.save
        # give the new group permissions to the folders
        give_permissions_to_folders(@group, params[:permission_to_everything][:checked] == 'yes' ? true : false)

        redirect_to :action => 'list'
      else
        render :action => 'new'
      end
    end
  end

  # Show a form in which the group can be renamed
  def rename
    render
  end

  # Update the group attributes with the posted variables from the 'edit' view.
  def update
    if request.post?
      if @group.update_attributes(params[:group])
        redirect_to :action => 'list'
      else
        render :action => 'rename'
      end
    end
  end

  # Delete a group.
  def destroy
    @group.destroy
    redirect_to :action => 'list'
  end

  # These methods are private:
  # [#give_permissions_to_folders]         Give a given group permissions
  # [#add_to_group_permissions]            Add the given group and folder to GroupPermissions
  # [#do_not_edit_or_destroy_admins_group] Via before_filter: make sure admins is not edited/deleted
  # [#does_group_exist]                    Check if a group exists
  private
    # Give the given group either ALL or NO
    # permissions to all the folders
    def give_permissions_to_folders(group, permission_to_everything)
      Folder.find(:all).each do |folder|
        add_to_group_permissions(group, folder, permission_to_everything)
      end
    end

    # Add the given group and folder to GroupPermissions
    # and (dis)allow everything
    def add_to_group_permissions(group, folder, permission_to_everything)
      group_permission = GroupPermission.new
      group_permission.folder = folder
      group_permission.group = group
      group_permission.can_create = permission_to_everything
      group_permission.can_read = permission_to_everything
      group_permission.can_update = permission_to_everything
      group_permission.can_delete = permission_to_everything
      group_permission.save
    end

    # The group called 'admins' can not be edited or deleted.
    # By calling this method via a before_filter,
    # you makes sure this doesn't happen.
    def do_not_rename_or_destroy_admins_group
      if @group and @group.is_the_administrators_group?
        redirect_to :action => 'list' and return false
      end
    end

    # Check if a group exists before executing an action.
    # If it doesn't exist: redirect to 'list' and show an error message
    def does_group_exist
      @group = Group.find(params[:id])
    rescue
      flash.now[:group_error] = 'Someone else deleted the group. Your action was cancelled.'
      redirect_to :action => 'list' and return false
    end
end