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

ActiveRecord::Schema.define(:version => 20100907103941) do

  create_table "Messages", :force => true do |t|
    t.string   "email_id",          :limit => 100,                :null => false
    t.string   "subject",           :limit => 100,                :null => false
    t.text     "contents",                                        :null => false
    t.datetime "created_date_time",                               :null => false
    t.integer  "lock_version",      :limit => 8,   :default => 0, :null => false
  end

  create_table "Recipients", :force => true do |t|
    t.string  "email_id",       :limit => 100,                :null => false
    t.integer "message_id",     :limit => 8,                  :null => false
    t.string  "message_status", :limit => 35,                 :null => false
    t.integer "lock_version",   :limit => 8,   :default => 0, :null => false
  end

  create_table "Users", :force => true do |t|
    t.string  "user_id",      :limit => 25,                 :null => false
    t.string  "user_name",    :limit => 50,                 :null => false
    t.integer "lock_version", :limit => 8,   :default => 0, :null => false
    t.string  "email_id",     :limit => 100,                :null => false
  end

end
