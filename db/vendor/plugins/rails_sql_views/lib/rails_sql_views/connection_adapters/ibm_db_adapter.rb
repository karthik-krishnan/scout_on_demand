module Db2ViewDdlAdditions
   # Returns true as this adapter supports views.
   def supports_views?
     true
   end

   def tables(name = nil) #:nodoc:
     tables = []
     execute("SELECT TABLE_NAME FROM SYSIBM.TABLES", name).each { |row| tables << row[0]  }
     tables
   end

   def views(name = nil) #:nodoc:
     views = []
     execute("SELECT TABLE_NAME FROM SYSIBM.VIEWS", name).each { |row| views << row[0] }
     views
   end

   # Get the view select statement for the specified table.
   def view_select_statement(view, name=nil)
     row = execute("SELECT VIEW_DEFINITION FROM SYSIBM.VIEWS WHERE TABLE_NAME = '#{view}'", name).each do |row|
       return row[0]
     end
     raise "No view called #{view} found"
   end
  
end

if RUBY_PLATFORM =~ /java/
  module ActiveRecord
    module ConnectionAdapters # :nodoc:
      class JdbcAdapter 
        include Db2ViewDdlAdditions if db2?
      end
    end
  end
  
else
  
  module ActiveRecord
    module ConnectionAdapters
      class IBM_DBAdapter < AbstractAdapter
        include Db2ViewDdlAdditions if db2?
      end
    end
  end
end
