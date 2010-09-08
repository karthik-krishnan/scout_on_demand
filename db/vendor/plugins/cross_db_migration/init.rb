# Include hook code here

require 'cross_db_migration'

ActiveRecord::Base.send(:include, ActiveRecord::ConnectionAdapters::SchemaStatements)

