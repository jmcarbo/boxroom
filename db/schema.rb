# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 4) do

  create_table "folders", :force => true do |t|
    t.string   "name"
    t.datetime "date_modified"
    t.integer  "user_id",       :default => 0
    t.integer  "parent_id",     :default => 0
    t.boolean  "is_root",       :default => false
  end

  add_index "folders", ["date_modified"], :name => "index_folders_on_date_modified"
  add_index "folders", ["is_root"], :name => "index_folders_on_is_root"
  add_index "folders", ["name"], :name => "index_folders_on_name"
  add_index "folders", ["parent_id"], :name => "index_folders_on_parent_id"
  add_index "folders", ["user_id"], :name => "index_folders_on_user_id"

  create_table "group_permissions", :force => true do |t|
    t.integer "folder_id",  :default => 0
    t.integer "group_id",   :default => 0
    t.boolean "can_create", :default => false
    t.boolean "can_read",   :default => false
    t.boolean "can_update", :default => false
    t.boolean "can_delete", :default => false
  end

  add_index "group_permissions", ["can_create"], :name => "index_group_permissions_on_can_create"
  add_index "group_permissions", ["can_delete"], :name => "index_group_permissions_on_can_delete"
  add_index "group_permissions", ["can_read"], :name => "index_group_permissions_on_can_read"
  add_index "group_permissions", ["can_update"], :name => "index_group_permissions_on_can_update"
  add_index "group_permissions", ["folder_id"], :name => "index_group_permissions_on_folder_id"
  add_index "group_permissions", ["group_id"], :name => "index_group_permissions_on_group_id"

  create_table "groups", :force => true do |t|
    t.string  "name"
    t.boolean "is_the_administrators_group", :default => false
  end

  add_index "groups", ["is_the_administrators_group"], :name => "index_groups_on_is_the_administrators_group"
  add_index "groups", ["name"], :name => "index_groups_on_name"

  create_table "groups_users", :id => false, :force => true do |t|
    t.integer "group_id", :default => 0
    t.integer "user_id",  :default => 0
  end

  add_index "groups_users", ["group_id", "user_id"], :name => "index_groups_users_on_group_id_and_user_id"

  create_table "myfiles", :force => true do |t|
    t.string   "filename"
    t.integer  "filesize"
    t.datetime "date_modified"
    t.integer  "folder_id",     :default => 0
    t.integer  "user_id",       :default => 0
    t.boolean  "indexed",       :default => false
  end

  add_index "myfiles", ["date_modified"], :name => "index_myfiles_on_date_modified"
  add_index "myfiles", ["filename"], :name => "index_myfiles_on_filename"
  add_index "myfiles", ["filesize"], :name => "index_myfiles_on_filesize"
  add_index "myfiles", ["folder_id"], :name => "index_myfiles_on_folder_id"
  add_index "myfiles", ["indexed"], :name => "index_myfiles_on_indexed"
  add_index "myfiles", ["user_id"], :name => "index_myfiles_on_user_id"

  create_table "usages", :force => true do |t|
    t.datetime "download_date_time"
    t.integer  "myfile_id",          :default => 0
    t.integer  "user_id",            :default => 0
  end

  add_index "usages", ["download_date_time"], :name => "index_usages_on_download_date_time"
  add_index "usages", ["myfile_id"], :name => "index_usages_on_myfile_id"
  add_index "usages", ["user_id"], :name => "index_usages_on_user_id"

  create_table "users", :force => true do |t|
    t.string  "name"
    t.string  "email"
    t.string  "hashed_password"
    t.boolean "is_the_administrator", :default => false
    t.string  "password_salt"
    t.string  "rss_access_key"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["hashed_password"], :name => "index_users_on_hashed_password"
  add_index "users", ["is_the_administrator"], :name => "index_users_on_is_the_administrator"
  add_index "users", ["name"], :name => "index_users_on_name"
  add_index "users", ["password_salt"], :name => "index_users_on_password_salt"
  add_index "users", ["rss_access_key"], :name => "index_users_on_rss_access_key"

end
