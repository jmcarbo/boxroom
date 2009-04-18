class AddIndexedFieldToMyfiles < ActiveRecord::Migration
  def self.up
    # Add indexed column to Myfiles, used to see which files were indexed by Ferret (SH)
    add_column :myfiles, 'indexed', :boolean, :default => false
    add_index :myfiles, :indexed
  end

  def self.down
    remove_column :myfiles, :indexed
  end
end