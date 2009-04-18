class AddAccessKeyColumnToUserTable < ActiveRecord::Migration
  def self.up
    # Add rss_access_key column to the users table.
    add_column :users, 'rss_access_key', :string
    add_index :users, :rss_access_key

    # Set random access keys for current users.
    for u in User.find(:all)
      u.rss_access_key = User.random_password(36)
      u.save
    end
  end

  def self.down
    remove_index :users, :rss_access_key
    remove_column :users, 'rss_access_key'
  end
end