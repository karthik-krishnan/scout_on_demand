class CreateRecipients < ActiveRecord::Migration
  def self.up
    create_table :Recipients do |t|
      t.string  :email_id, :limit => 100, :null => false
      t.integer :message_id, :null => false
      t.string  :message_status, :limit => 35, :null => false
      t.integer :lock_version, :default => 0, :null => false
    end
  end

  def self.down
  end
  
end
