# Helper methods for folder views
module FolderHelper
  # Creates a link in the folder list view. Clicking the link will order the contents of a folder
  # by the field supplied in order_by. If the contents of the folder are already ordered by 'order_by',
  # clicking the link will reverse the order. This helper only generates the links for this. The actual
  # functionality is implemented in FolderController.list
  def link_order(name, order_by)
    if params[:order] == nil and params[:order_by] == order_by
      link_to(name, :action => 'list', :id => params[:id], :order_by => order_by, :order => 'DESC') + image_tag('asc.png')
    elsif params[:order] and params[:order_by] == order_by
      link_to(name, :action => 'list', :id => params[:id], :order_by => order_by) + image_tag('desc.png')
    else
      link_to name, :action => 'list', :id => params[:id], :order_by => order_by
    end
  end

  # Creates a check box and checks/unchecks, disables it depending on the given parameters.
  # The name of the check box is based on the given type.
  # This helper method is used for show the permission in the folder list view.
  def CRUD_check_box(type, group_id, folder_id, disabled)
    case type
    when 'create'
      checked = GroupPermission.find_by_group_id_and_folder_id(group_id, folder_id).can_create ? 'checked' : ''
      check_box('create_check_box', group_id, {:checked => checked, :disabled => disabled, :onclick => 'CheckRead(this.checked, ' + group_id.to_s + ')'}) 
    when 'read'
      checked = GroupPermission.find_by_group_id_and_folder_id(group_id, folder_id).can_read ? 'checked' : ''
      check_box('read_check_box', group_id, {:checked => checked, :disabled => disabled, :onclick => 'UncheckCreateUpdateDelete(this.checked, ' + group_id.to_s + ')'})
    when 'update'
      checked = GroupPermission.find_by_group_id_and_folder_id(group_id, folder_id).can_update ? 'checked' : ''
      check_box('update_check_box', group_id, {:checked => checked, :disabled => disabled, :onclick => 'CheckRead(this.checked, ' + group_id.to_s + ')'})
    when 'delete'
      checked = GroupPermission.find_by_group_id_and_folder_id(group_id, folder_id).can_delete ? 'checked' : ''
      check_box('delete_check_box', group_id, {:checked => checked, :disabled => disabled, :onclick => 'CheckRead(this.checked, ' + group_id.to_s + ')'})
    end
  end
end