# The Create/Read/Update/Delete permissions groups have
# on folders are stored in GroupPermissions
class GroupPermission < ActiveRecord::Base
  belongs_to :group
  belongs_to :folder

  # Create initial permissions.
  # The admins group get permission on the Root folder.
  # This method assumes the admins group exists and Root folder exists.
  def self.create_initial_permissions
    # Get the root folder and the admins group
    root_folder = Folder.find_by_is_root(true)
    admins_group = Group.find_by_is_the_administrators_group(true)

    # Create the permissions
    unless root_folder.blank? or admins_group.blank?
      group_permission = GroupPermission.new
      group_permission.folder = root_folder
      group_permission.group = admins_group
      group_permission.can_create = true
      group_permission.can_read = true
      group_permission.can_update = true
      group_permission.can_delete = true
      group_permission.save
    end
  end
end