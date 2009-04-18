class AddPasswordSaltToUser < ActiveRecord::Migration
  def self.up
    # Add password_salt column to the users table.
    add_column :users, 'password_salt', :string
    add_index :users, :password_salt

    # Set the salt for current users to empty.
    # This way passwords stay valid.
    for u in User.find(:all)
      u.password_salt = ''
      u.save
    end
  end

  def self.down
    remove_index :users, :password_salt
    remove_column :users, 'password_salt'
  end
end