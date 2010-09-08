class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :Users do |t|
      t.column :user_id, :string, :limit => 25, :null => false
      t.column :user_name, :string, :limit => 50, :null => false
      t.column :lock_version, :integer, :default => 0, :null => false
    end
  end

  def self.down
    drop_table :Users
  end
end
