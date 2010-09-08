class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :Messages, :force => true do |t|
      t.string  :email_id, :limit => 100, :null => false
      t.string  :subject, :limit => 100, :null => false
      t.text    :contents, :null => false
      t.datetime :created_date_time, :null => false
      t.integer :lock_version, :default => 0, :null => false
    end

    add_column :Users, :email_id, :string, :limit => 100, :null => true
    execute "UPDATE Users SET email_id = 'a@b.com'"
    change_column :Users, :email_id, :string, :limit => 100, :null => false
  end

  def self.down
  end
end
