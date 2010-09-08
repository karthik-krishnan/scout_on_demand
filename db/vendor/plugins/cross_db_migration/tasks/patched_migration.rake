desc "Run migrations to output DDL SQL"
task :patched_migration => :environment do
  ActiveRecord::Base.connection.class.class_eval do
    # alias the adapter's execute for later use
    alias :old_execute :execute
	File.open( File.join(RAILS_ROOT, 'db', 'ddl.sql'),'w') {|f|
		if ActiveRecord::Base.connection.adapter_name == 'Oracle' then
			f.puts "ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';"
			f.puts "ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS';"
		else
			f.puts ""
		end
	}
		
    # define our own execute
    def execute(sql, name = nil)   
      # Only skip select statements from logging 
      unless /^(select|show|begin|commit)/i.match(sql.strip)  
		File.open( File.join(RAILS_ROOT, 'db', 'ddl.sql'),'a') {|f|
			temp_sql = sql.gsub("\n","") 
			temp_sql = temp_sql + ';' if adapter_name != 'IBM_DB2' or adapter_name != 'IBM_DB'
			f.puts temp_sql
		}
      end
	  old_execute sql, name
    end
  end
  
	module ActiveRecord
	  module ConnectionAdapters # :nodoc:
		 module SchemaStatements
			alias_method :create_table_with_force, :create_table
			def create_table(name, options = {}, &block)
				options[:force] = false if options[:force] == true
				create_table_with_force(name, options, &block)
			end
		end                     
	  end                                                         
	end

  # invoke the normal migration procedure now
  # that we've monkey patched the connection
  Rake::Task["db:migrate"].invoke
end
