# CrossDbMigration

module ActiveRecord
  module ConnectionAdapters # :nodoc:
    module SchemaStatements
      alias_method :add_column_without_db2_not_null, :add_column
      alias_method :create_table_without_length_check, :create_table
      def add_column(table_name, column_name, type, options = {})
        raise "can not specify limit for the integer datatype" if type.to_s.upcase.strip == "INTEGER"  && options[:limit] != nil
        raise "Column name should be less than or equal to 30 characters in length" if column_name.to_s.length > 30
        is_null_allowed = false
        if  db2? && options[:null] == false then
          options[:null] = true
          is_null_allowed = true
        end            
        add_column_without_db2_not_null(table_name, column_name, type, options)
        if  db2? && is_null_allowed == true then
          execute("ALTER TABLE #{table_name} ALTER COLUMN #{column_name} SET NOT NULL")
          execute("CALL ADMIN_CMD('REORG TABLE #{table_name}')")
        end
        recompile_triggers(table_name) if oracle?
      end
      def create_table(name, options = {}, &block)
        if options[:skip_table_name_length_check] == true
          raise "Table name should be less than or equal to 30 characters in length" if name.to_s.length > 30
        else
          raise "Table name should be less than or equal to 26 characters in length" if name.to_s.length > 26
        end  
        options[:options] = options[:options] +" CHARACTER SET utf8 " unless name.starts_with?("FLUX_") if mysql?
        create_table_without_length_check(name, options, &block)
        execute("comment ON table #{name} is '#{name}'") if oracle?
      end
    end                     
  end
  class SchemaDumper

    def dump(stream)
      header(stream)
      tables(stream)
      oracle_functions_and_triggers(stream) if oracle?
      oracle_packages(stream) if oracle?
      trailer(stream)
      stream
    end
    
    def table(table, stream)
      columns = @connection.columns(table)
      begin
        tbl = StringIO.new
        if @connection.respond_to?(:pk_and_sequence_for)
          pk, pk_seq, auto_increment = @connection.pk_and_sequence_for(table)
        end
        #pk ||= 'id' if auto_increment
        pk ||= 'id'
        if oracle? then
          table_name = @connection.select_one("SELECT comments FROM user_tab_comments WHERE table_name = '#{table.upcase}'")['comments']
        else
          table_name = table
        end
        tbl.print "  create_table :#{table_name}"
        if columns.each { |c| c.name == pk }
          #if pk != 'id'
          if auto_increment == 1
            tbl.print %Q(, :primary_key => :#{pk.to_s.downcase})
          else
            tbl.print ", :id => false"
          end
        end
        tbl.print ", :force => true"
        tbl.puts " do |t|"

        column_specs = columns.map do |column|
          raise StandardError, "Unknown type '#{column.sql_type}' for column '#{column.name}'" if @types[column.type].nil?
          next if column.name.to_s.downcase == pk.to_s.downcase && auto_increment == 1
          spec = {}
          spec[:name]      = ':' + column.name
          spec[:type]      = column.type.to_s
          unless column.type == :integer || column.type == :binary
            spec[:limit]     = column.limit.inspect if column.limit != @types[column.type][:limit] && column.type != :decimal
            spec[:precision] = column.precision.inspect if !column.precision.nil?
            spec[:scale]     = column.scale.inspect if !column.scale.nil?
          end
          spec[:null]      = 'false' if !column.null
          spec[:default]   = default_string(column.default) if column.has_default?
          (spec.keys - [:name, :type]).each{ |k| spec[k].insert(0, "#{k.inspect} => ")}
          spec
        end.compact

        # find all migration keys used in this table
        keys = [:name, :limit, :precision, :scale, :default, :null] & column_specs.map(&:keys).flatten

        # figure out the lengths for each column based on above keys
        lengths = keys.map{ |key| column_specs.map{ |spec| spec[key] ? spec[key].length + 2 : 0 }.max }

        # the string we're going to sprintf our values against, with standardized column widths
        format_string = lengths.map{ |len| "%-#{len}s" }

        # find the max length for the 'type' column, which is special
        type_length = column_specs.map{ |column| column[:type].length }.max

        # add column type definition to our format string
        format_string.unshift "    t.%-#{type_length}s "

        format_string *= ''

        column_specs.each do |colspec|
          values = keys.zip(lengths).map{ |key, len| colspec.key?(key) ? colspec[key] + ", " : " " * len }
          values.unshift colspec[:type]
          tbl.print((format_string % values).gsub(/,\s*$/, ''))
          tbl.puts
        end
        pri_key = ''
        pri_key = ":#{pk.join(", :")}"
        if auto_increment == 0
          tbl.puts "    t.pk #{pri_key.downcase}" unless pk.size == 0
        end
        tbl.puts "  end"
        tbl.puts

        indexes(table, tbl)
        oracle_check_constraints(table, tbl) if oracle?
        oracle_unique_constraints(table, tbl) if oracle?
        generate_sql_for_default_data(table, tbl)
        tbl.rewind
        stream.print tbl.read
      rescue => e
        stream.puts "# Could not dump table #{table.inspect} because of following #{e.class}"
        stream.puts "#   #{e.message}"
        stream.puts
      end

      stream
    end

    def oracle_check_constraints(table, stream)
      check_constraints = @connection.select_all("SELECT * FROM USER_CONSTRAINTS WHERE TABLE_NAME = '#{table.upcase}' AND
        CONSTRAINT_TYPE = 'C' AND CONSTRAINT_NAME NOT LIKE 'SYS_%'")
      if check_constraints
        table_name = @connection.select_one("SELECT comments FROM user_tab_comments WHERE table_name = '#{table.upcase}'")['comments']
        add_constraint_statements = []
        check_constraints.each do |constraint|
          statement_parts = [ ('add_constraint :' + table_name)]
          statement_parts << ":name => \"#{constraint['constraint_name'].downcase}\""
          statement_parts << ":check => \"#{constraint['search_condition']}\""
          add_constraint_statements << '  ' + statement_parts.join(', ')
        end
        stream.puts add_constraint_statements.sort.join("\n")
        stream.puts
      end
    end

    def oracle_unique_constraints(table, stream)
      unique_constraints = @connection.select_all("SELECT * FROM USER_CONSTRAINTS WHERE TABLE_NAME = '#{table.upcase}' AND
        CONSTRAINT_TYPE = 'U' AND CONSTRAINT_NAME NOT LIKE 'SYS_%'")
      if unique_constraints
        table_name = @connection.select_one("SELECT comments FROM user_tab_comments WHERE table_name = '#{table.upcase}'")['comments']
        add_constraint_statements = []
        unique_constraints.each do |constraint|
          statement_parts = [ ('add_constraint :' + table_name)]
          statement_parts << ":name => \"#{constraint['constraint_name'].downcase}\""
          constraint_columns = @connection.select_all("SELECT column_name FROM USER_CONS_COLUMNS WHERE constraint_name = '#{constraint['constraint_name']}' ORDER BY position")
          const_columns = []
          constraint_columns.each{|c| const_columns << c['column_name']}
          statement_parts << ":unique => [:#{const_columns.join(', :')}]"
          add_constraint_statements << '  ' + statement_parts.join(', ')
        end
        stream.puts add_constraint_statements.sort.join("\n")
        stream.puts
      end
    end

    def oracle_functions_and_triggers(stream)
      fun_name = @connection.select_all("SELECT UNIQUE(name) FROM USER_SOURCE WHERE TYPE IN ('TRIGGER', 'FUNCTION')")
      add_function_statements = []
      statements = []
      fun_name.each{|f|
        statement_parts = [ ('execute "create ')]
        fun_code = @connection.select_all("SELECT text FROM USER_SOURCE WHERE name = '#{f['name']}' ORDER BY line")
        fun_code.each{|fc|
          statement_parts <<  fc['text']
        }
        statements << statement_parts.join
      }
      add_function_statements << '  ' +  statements.join('"' + $/ )
      stream.puts add_function_statements << '"'
      stream.puts
    end

    def oracle_packages(stream)
      fun_name = @connection.select_all("SELECT UNIQUE(name) FROM USER_SOURCE WHERE TYPE = 'PACKAGE'")
      add_function_statements = []
      #Package
      statements = []
      fun_name.each{|f|
        statement_parts = [ ('execute "create ')]
        fun_code = @connection.select_all("SELECT text FROM USER_SOURCE WHERE name = '#{f['name']}' AND TYPE = 'PACKAGE' ORDER BY line")
        fun_code.each{|fc|
          statement_parts <<  fc['text']
        }
        statements << statement_parts.join
      }
      add_function_statements << '  ' +  statements.join('"' + $/ )
      add_function_statements << '"'
      # Package Body
      statements = []
      fun_name.each{|f|
        statement_parts = [ ('execute "create ')]
        fun_code = @connection.select_all("SELECT text FROM USER_SOURCE WHERE name = '#{f['name']}' AND TYPE = 'PACKAGE BODY' ORDER BY line")
        fun_code.each{|fc|
          statement_parts <<  fc['text']
        }
        statements << statement_parts.join
      }
      add_function_statements << '  ' +  statements.join('"' + $/ )
      add_function_statements << '"'
      stream.puts add_function_statements
      stream.puts
    end

    def generate_sql_for_default_data(table, stream)
      cols = []
      columns = []
      @connection.columns(table).each{|c| cols << c.name }
      @connection.columns(table).each{|c| columns << [c.name, c.type] }
      if oracle?
        table_name = @connection.select_one("SELECT comments FROM user_tab_comments WHERE table_name = '#{table.upcase}'")['comments']
      else
        table_name = table
      end
      select_sql = "SELECT #{cols.join(",")} FROM #{table}"
      
      @connection.select_all(select_sql).each{|r|
        records = []
        columns.each{|c|
          if r[c[0]].nil?
            column_value = 'NULL'
          else
            column_value = r[c[0]]
          end

          if c[1] == :string or c[1] == :text
            records << "'#{(column_value.gsub('"', "\\\"").gsub("'", "\\\""))}'"
          elsif c[1] == :datetime
            column_value = "'#{column_value.strftime("%Y-%m-%d %H:%M:%S" )}'" unless column_value == 'NULL'
            records << column_value
          else
            records << column_value
          end
        }
        rec = records.join(",")
        rec = "#{rec}"
        insert_rec = rec.gsub(/'NULL'/, 'NULL')
        stream.puts "execute \"INSERT INTO #{table_name} (#{cols.join(",")}) VALUES (#{insert_rec})\""
        
      }
    end

    def indexes(table, stream)
      if (indexes = @connection.indexes(table)).any?
        if oracle?
          table_name = @connection.select_one("SELECT comments FROM user_tab_comments WHERE table_name = '#{table.upcase}'")['comments']
        else
          table_name = table
        end
        add_index_statements = indexes.map do |index|
          statment_parts = [ ('add_index :' + table_name) ]
          statment_parts << index.columns.inspect
          statment_parts << (':name => ' + index.name.inspect)
          statment_parts << ':unique => true' if index.unique

          '  ' + statment_parts.join(', ')
        end

        stream.puts add_index_statements.sort.join("\n")
        stream.puts
      end
    end
  end
end

module CommonDdlCustomizations
  def self.included(klass)
    klass.class_eval do
      def rename_table(name, new_name)
        raise "Rename table is not allowed in this migration, Instead create a view with the new name"
      end
      def rename_column(table_name, column_name, new_column_name)
        raise "Rename column is not allowed in this migration"
      end
    end
  end
end

module Db2DdlCustomizations
  def self.included(klass)
    klass.class_eval do
      include CommonDdlCustomizations
      alias_method :change_column_default, :change_column
  
      def change_column(table_name, column_name, type, options = {})
        raise "can not specify limit for the integer datatype" if type.to_s.upcase.strip == "INTEGER" && options[:limit] != nil
        sql = "SELECT COLTYPE, LENGTH, DEFAULT FROM SYSIBM.SYSCOLUMNS WHERE TBNAME = UPPER('#{table_name}') and NAME = UPPER('#{column_name}')"
        col_info = nil
        begin
          col_info = select_one(sql)
        rescue
          col_info = select_one(sql)
        end
        column_type = col_info["coltype"].upcase.strip
        data_length = col_info["length"]
        native_type = native_database_types[type.to_sym][:name].upcase.strip
        column_default = col_info["default"]

        if column_type != native_type
          raise "#{table_name}-#{column_name} column to be modified must be of same datatype(#{column_type} <> #{native_type})" if column_type != 'TIMESTMP' && native_type != 'TIMESTAMP'
        end
        #raise "column to be modified must be of same datatype" if column_type != native_type
        raise "The limit should be greater than the existing value" if options[:limit] != nil && options[:limit] < data_length
        if type == :string then
          change_column_default(table_name, column_name, type, options)
        end
        if options[:null] == false then
          execute("ALTER TABLE #{table_name} ALTER COLUMN #{column_name} SET NOT NULL")
          execute("CALL ADMIN_CMD('REORG TABLE #{table_name}')")
        elsif options[:null] == true
          execute("ALTER TABLE #{table_name} ALTER COLUMN #{column_name} DROP NOT NULL")
          execute("CALL ADMIN_CMD('REORG TABLE #{table_name}')")
        end
        if !options[:default].nil? && options[:default] != column_default then
          if type == :string then
            execute("ALTER TABLE #{table_name} ALTER COLUMN #{column_name} SET DEFAULT '#{options[:default]}'")
          else
            execute("ALTER TABLE #{table_name} ALTER COLUMN #{column_name} SET DEFAULT #{options[:default]}")
          end
          execute("CALL ADMIN_CMD('REORG TABLE #{table_name}')")
        end
      end
      alias_method :native_database_types_default, :native_database_types
      def native_database_types #:nodoc:
        native_database_types_default.merge!(:integer => { :name => "bigint" })
      end
    end
  end
end
module OracleDdlCustomizations
  def self.included(klass)
    klass.class_eval do
      include CommonDdlCustomizations
      alias_method :change_column_default, :change_column
  
      def change_column(table_name, column_name, type, options = {})
        raise "can not specify limit for the integer datatype" if type.to_s.upcase.strip == "INTEGER"  && options[:limit] != nil
        sql = "SELECT DATA_TYPE, DATA_LENGTH FROM USER_TAB_COLS WHERE table_name = upper('#{table_name}') and column_name = upper('#{column_name}')"
        column_type = select_one(sql)["data_type"].upcase.strip
        native_type = native_database_types[type.to_sym][:name].upcase.strip
        data_length = select_one(sql)["data_length"]
        native_type = 'NUMBER' if native_type == 'DECIMAL' # Even if we specify the native datatype 'decimal', Oracle internally stores the decimal datatype as number.
        raise "#{table_name}-#{column_name} column to be modified must be of same datatype(#{column_type} <> #{native_type})" if column_type != native_type
        raise "The limit should be greater than the existing value" if options[:limit] != nil && options[:limit] < data_length
        change_column_default table_name, column_name, type, options
        recompile_triggers(table_name)
      end
      alias_method :remove_column_default, :remove_column

      def remove_column(table_name, *column_names)
        remove_column_default(table_name, *column_names)
        recompile_triggers(table_name)
      end

      alias_method :add_column_options_default, :add_column_options!
      def add_column_options!(sql, options) #:nodoc:
        sql << " DEFAULT #{quote(options[:default], options[:column])}" if options_include_default?(options)
        sql << " NOT NULL" if options[:null] == false
        sql << " NULL" if options[:null] == true
      end
      def pk_and_sequence_for(table_name)
        (owner, table_name) = @connection.describe(table_name)

        pks = select_values(<<-SQL, 'Primary Key')
          select cc.column_name
            from all_constraints c, all_cons_columns cc
          where c.owner = '#{owner}'
               and c.table_name = '#{table_name}'
               and c.constraint_type = 'P'
               and cc.owner = c.owner
               and cc.constraint_name = c.constraint_name
          ORDER BY position
        SQL

        if pks.size > 1
          auto_increment = 0
        else
          column_data_type = select_values(<<-SQL, 'Column Data Type')
          SELECT data_type
            FROM all_tab_columns
          WHERE owner = '#{owner}'
               and table_name = '#{table_name}'
               and column_name = '#{pks}'
          SQL

          if column_data_type.to_s == 'NUMBER'
            auto_increment = 1
          else
            auto_increment = 0
          end
        end
        [pks, nil, auto_increment.to_i]
      end
    end
  end
end

module MysqlDdlCustomizations
  def self.included(klass)
    klass.class_eval do
      include CommonDdlCustomizations
      alias_method :change_column_default, :change_column
      def change_column(table_name, column_name, type, options = {})
        raise "can not specify limit for the integer datatype" if type.to_s.upcase.strip == "INTEGER" && options[:limit] != nil
        db_name = current_database
        sql = "SELECT data_type, character_maximum_length FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '#{table_name}' and COLUMN_NAME = '#{column_name}' and table_schema = '#{db_name}'"
        column_type = select_one(sql)["data_type"].upcase.strip
        native_type = native_database_types[type.to_sym][:name].upcase.strip
        if select_one(sql)["character_maximum_length"] != nil then
          data_length = select_one(sql)["character_maximum_length"]
        else
          data_length = 0
        end
        raise "#{table_name}-#{column_name} column to be modified must be of same datatype(#{column_type} <> #{native_type})" if column_type != native_type
        raise "The limit should be greater than the existing value" if options[:limit] != nil && options[:limit] < data_length.to_i

        #Here we overridden the default change_column code.
        #Reason: empty string is assigned if the default is not specified for a integer column ( while defining as well as changing )
        unless options_include_default?(options)
          options[:default] = select_one("SHOW COLUMNS FROM #{table_name} LIKE '#{column_name}'")["Default"]
          options[:default] = nil if options[:default] == "" && type != :string
        end

        existing_allow_null_option = select_one("SHOW COLUMNS FROM #{table_name} LIKE '#{column_name}'")["Null"]
        options[:null] = TRUE if options[:null] == nil and existing_allow_null_option == 'YES'
        options[:null] = FALSE if options[:null] == nil and existing_allow_null_option == 'NO'

        change_column_sql = "ALTER TABLE #{table_name} CHANGE #{column_name} #{column_name} #{type_to_sql(type, options[:limit], options[:precision], options[:scale])}"
        add_column_options!(change_column_sql, options)
        execute(change_column_sql)
      end
      
      def pk_and_sequence_for(table) #:nodoc:
        auto = 0
        keys = []
        execute("describe #{quote_table_name(table)}").each_hash do |h|
          auto = 1 if h["Extra"] == 'auto_increment'
          keys << h["Field"]if h["Key"] == "PRI"
        end
        #keys.length == 1 ? [keys.first, nil] : nil
        [keys, nil, auto]
      end

      alias_method :native_database_types_default, :native_database_types
      def native_database_types #:nodoc:
        native_database_types_default.merge!( :primary_key => "bigint DEFAULT NULL auto_increment PRIMARY KEY",
          :integer => { :name => "bigint" },
          :binary => { :name => "longblob"})
        
      end
      alias_method :type_to_sql_default, :type_to_sql
      def type_to_sql(type, limit = nil, precision = nil, scale = nil)
        limit = 5 if type.to_s == 'integer' && limit == nil
        type_to_sql_default type, limit, precision, scale
      end
    end
  end
end


if RUBY_PLATFORM =~ /java/
  module ActiveRecord
    module ConnectionAdapters # :nodoc:
      class JdbcAdapter
        include MysqlDdlCustomizations if mysql?
        include OracleDdlCustomizations if oracle?
        include Db2DdlCustomizations if db2?
      end
    end
  end
else
  # Migration is failing because of this session level settings
  # Commenting this code as we need to discuss about the case insensitive search in db2 as well as in oracle
  # For oracle we are planning to release logon trigger to set these nls parameter
  #  if oracle?
  #    class OracleConnectionFactory #:nodoc:
  #      alias_method :new_connection_without_case_insensitive_search_settings, :new_connection
  #      def new_connection(username, password, database, async, prefetch_rows, cursor_sharing)
  #        conn = new_connection_without_case_insensitive_search_settings(username, password, database, async, prefetch_rows, cursor_sharing)
  #        conn.exec %q{ALTER session SET nls_sort = binary_ci} rescue nil
  #        conn.exec %q{ALTER session SET nls_comp = 'LINGUISTIC'} rescue nil
  #        conn
  #      end
  #    end
  #  end
  module ActiveRecord
    module ConnectionAdapters # :nodoc:
      class IBM_DBAdapter < AbstractAdapter
        include Db2DdlCustomizations if db2?
      end
    end
  end


  module ActiveRecord
    module ConnectionAdapters # :nodoc:
      class OracleAdapter < AbstractAdapter
        include OracleDdlCustomizations if oracle?
      end
    end
  end
  
  module ActiveRecord
    module ConnectionAdapters # :nodoc:
      class MysqlAdapter < AbstractAdapter
        include MysqlDdlCustomizations if mysql?
      end
    end
  end
end

module ActiveRecord
  module ConnectionAdapters
    class TableDefinition
      alias_method :column_without_length_check, :column
      def column(name, type, options = {})
        raise "can not specify limit for the integer datatype" if type.to_s.upcase.strip == "INTEGER" && options[:limit] != nil
        raise "Column name should be less than or equal to 30 characters in length" if name.to_s.length > 30
        column_without_length_check(name, type, options)
      end
    end
  end
end

module ActiveRecord
  module ConnectionAdapters
    module DatabaseStatements
      
      def db_specific_integer_data_type
        if  mysql? then
          'unsigned'
        else
          'integer'
        end
      end
    end
  end
end
def recompile_triggers(table_name)
  select_all("SELECT TRIGGER_NAME FROM USER_TRIGGERS WHERE table_name = '#{table_name.to_s.upcase}'").each{|t|
    execute "ALTER TRIGGER #{t['trigger_name']} COMPILE"
  }
end
