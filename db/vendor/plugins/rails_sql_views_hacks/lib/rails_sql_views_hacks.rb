# RailsSqlViewsHacks

module RailsSqlViews
  module ConnectionAdapters # :nodoc:
    module SchemaStatements
      alias_method :create_view_without_length_check, :create_view
      def create_view(name, select_query, options = {}, &block)
        raise "View name should be less than or equal to 30 characters in length" if name.to_s.length > 30
        if options[:check_option] then
          raise "Only CASCADED check option is supported" if options[:check_option] != 'CASCADED'
          options[:check_option] = ''
        end
        create_view_without_length_check(name, select_query, options, &block)
      end
    end
  end
end

module RailsSqlViews
  module ConnectionAdapters # :nodoc:
    class ViewDefinition
      alias_method :column_without_length_check, :column
      def column(name)
        raise "View column name should be less than or equal to 30 characters in length" if name.to_s.length > 30
        column_without_length_check(name)
      end
    end
  end
end


module MySqlViewDdlAdditionHacks
  def self.included(klass)
    klass.class_eval do
      def tables(name = nil) #:nodoc:
        tables = []
        execute("SHOW TABLE STATUS", name).each { |row| tables << row["Name"] if row["Comment"] != 'VIEW' }
        tables
      end
      
      def views(name = nil) #:nodoc:
        views = []
        execute("SHOW TABLE STATUS", name).each { |row| views << row["Name"] if row["Comment"] == 'VIEW' }
        views
      end
    end
  end    
end

if RUBY_PLATFORM =~ /java/
  module ActiveRecord
    module ConnectionAdapters # :nodoc:
      class JdbcAdapter 
        include MySqlViewDdlAdditionHacks if mysql?
      end
    end
  end
end

