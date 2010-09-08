require File.dirname(__FILE__) + '/../spec_helper'

describe CrossDbTest do
  before(:each) do
    #@cross_db_test = CrossDbTest.new
  end

  it "should raise error, if the skip_table_name_length_check option is false and length of table name is greater than 26 characters" do
    lambda {
      ActiveRecord::Migration.create_table :cross_db_test12345678901234 do |t|
        t.column :name, :string, :limit => 10
      end
    }.should raise_error('Table name should be less than or equal to 26 characters in length')
  end

  it "should raise error, if the skip_table_name_length_check option is true and length of table name is greater than 30 characters" do
    lambda {
      ActiveRecord::Migration.create_table :cross_db_test123456789012345678, :skip_table_name_length_check => true do |t|
        t.column :name, :string, :limit => 10
      end
    }.should raise_error('Table name should be less than or equal to 30 characters in length')
  end

  it "should create table with collation utf8_general_ci, if the database adapter is mysql" do
    if mysql? then
      ActiveRecord::Migration.create_table :CrossDbTest do |t|
        t.column :name, :string, :limit => 10
      end
      #select table_collation from information_schema.tables where table_name = 'CrossDbTest' and TABLE_SCHEMA = adapter.database name
      a = ActiveRecord::Base.connection.select_one "SELECT table_collation FROM information_schema.tables WHERE table_name = 'CrossDbTest'"
      # AND table_schema = database_name
      a['table_collation'].should eql('utf8_general_ci')
      ActiveRecord::Migration.drop_table :CrossDbTest
    end
  end

  it "should raise error, if the column name length is greater than 30 characters while creating a table" do
    lambda {
      ActiveRecord::Migration.create_table :cross_db_test do |t|
        t.column :name123456789012345678901234567, :string, :limit => 10
      end
    }.should raise_error('Column name should be less than or equal to 30 characters in length')
  end

  it "should raise error, if the tries to specify limit for integer datatype while creating a table" do
    lambda {
      ActiveRecord::Migration.create_table :cross_db_test do |t|
        t.column :name, :string, :limit => 10
        t.column :age, :integer, :limit => 20
      end
    }.should raise_error('can not specify limit for the integer datatype')
  end


  it "should raise error, if column name length is greater than 30 characters" do
    ActiveRecord::Migration.create_table :CrossDbTest do |t|
      t.column :name, :string, :limit => 10
    end
    lambda {
      ActiveRecord::Migration.add_column :CrossDbTest, :address123456789012345678901234, :string, :limit => 10
    }.should raise_error('Column name should be less than or equal to 30 characters in length')
    ActiveRecord::Migration.drop_table :CrossDbTest
  end

  it "should raise error, if tries to add a integer column with by specifying limit" do
    ActiveRecord::Migration.create_table :CrossDbTest do |t|
      t.column :name, :string, :limit => 10
    end
    lambda {
      ActiveRecord::Migration.add_column :CrossDbTest, :age, :integer, :limit => 20
    }.should raise_error('can not specify limit for the integer datatype')
    ActiveRecord::Migration.drop_table :CrossDbTest
  end

  it "should raise error, if tries to rename a table" do
    ActiveRecord::Migration.create_table :CrossDbTest do |t|
      t.column :name, :string, :limit => 10
    end
    lambda {
      ActiveRecord::Migration.rename_table :CrossDbTest, :CrossDbTest123
    }.should raise_error('Rename table is not allowed in this migration, Instead create a view with the new name')
    ActiveRecord::Migration.drop_table :CrossDbTest
  end

  it "should raise error, if tries to rename a column" do
    ActiveRecord::Migration.create_table :CrossDbTest do |t|
      t.column :name, :string, :limit => 10
    end
    lambda {
      ActiveRecord::Migration.rename_column :CrossDbTest, :name, :name123
    }.should raise_error('Rename column is not allowed in this migration')
    ActiveRecord::Migration.drop_table :CrossDbTest
  end

  it "should raise error, if tries to change the column datatype" do
    ActiveRecord::Migration.create_table :CrossDbTest do |t|
      t.column :name, :string, :limit => 10
    end
    lambda {
      ActiveRecord::Migration.change_column :CrossDbTest, :name, :integer
    }.should raise_error('CrossDbTest-name column to be modified must be of same datatype(VARCHAR <> BIGINT)')
    ActiveRecord::Migration.drop_table :CrossDbTest
  end

  it "should raise error, if tries to reduce the column limit" do
    ActiveRecord::Migration.create_table :CrossDbTest do |t|
      t.column :name, :string, :limit => 10
    end
    lambda {
      ActiveRecord::Migration.change_column :CrossDbTest, :name, :string, :limit => 9
    }.should raise_error('The limit should be greater than the existing value')
    ActiveRecord::Migration.drop_table :CrossDbTest
  end

  it "should raise error, if tries to specify limit for integer datatype" do
    ActiveRecord::Migration.create_table :CrossDbTest do |t|
      t.column :name, :string, :limit => 10
      t.column :age, :integer
    end
    lambda {
      ActiveRecord::Migration.change_column :CrossDbTest, :age, :integer, :limit => 20
    }.should raise_error('can not specify limit for the integer datatype')
    ActiveRecord::Migration.drop_table :CrossDbTest
  end
  
end
