# Groups are used to determine which groups of users have which rights
# on which folders.
class Group < ActiveRecord::Base
  has_many :group_permissions

  has_and_belongs_to_many :users

  validates_uniqueness_of :name
  validates_presence_of :name

  before_destroy :dont_destroy_admins
  # Don't delete 'admins' from the database
  def dont_destroy_admins
    raise "Can't delete admins group" if self.is_the_administrators_group?
  end

  after_destroy :destroy_dependant_group_permissions
  # Delete dependant group_permissions.
  # This code should be executed after_destroy.
  def destroy_dependant_group_permissions
    self.group_permissions.each do |group_permission|
      group_permission.destroy
    end
  end

  # Returns whether or not the admins group exists
  def self.admins_group_exists?
    group = Group.find_by_is_the_administrators_group(true)
    return (not group.blank?)
  end

  # Create admins group and add admin user to it.
  def self.create_admins_group
    if User.admin_exists? # and Group.admins_group_exists?
      group = Group.new
      group.name = 'admins'
      group.is_the_administrators_group = true

      # Add the adminstrator to this group:
      if user = User.find_by_is_the_administrator(true)
        user.groups.push(group)
      end

      group.save # save, so true is returned
    end
  end
end