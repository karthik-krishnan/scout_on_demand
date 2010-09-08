
module OracleViewDdlAdditions
  # Returns true as this adapter supports views.
  def supports_views?
    true
  end

  def tables(name = nil) #:nodoc:
    tables = []
    execute("SELECT TABLE_NAME FROM USER_TABLES", name).each { |row| tables << row[0]  }
    tables
  end

  def views(name = nil) #:nodoc:
    views = []
    select_all("SELECT VIEW_NAME FROM USER_VIEWS ORDER BY VIEW_NAME DESC", name).each { |row| views << row['view_name'] }
    views
  end

  # Get the view select statement for the specified table.
  def view_select_statement(view, name=nil)
    row = select_all("SELECT TEXT FROM USER_VIEWS WHERE VIEW_NAME = '#{view}'", name).each do |row|
      return row['text']
    end
    raise "No view called #{view} found"
  end
  
  
end

if RUBY_PLATFORM =~ /java/
  module ActiveRecord
    module ConnectionAdapters # :nodoc:
      class JdbcAdapter 
        include OracleViewDdlAdditions if oracle?
      end
    end
  end
  
else
  
  module ActiveRecord
    module ConnectionAdapters
      class OracleAdapter
        include OracleViewDdlAdditions if oracle?
      end
    end
  end
end
   
