alias_task "original_test_purge" , "db:test:purge"

#Under the normal schema dump approach, Rails 2.x now has the smarts to check whether your db is up to date.
#However, for the migration approach to create test db, the smarts is not only NOT required, it will hinder the 
#solution itself. Hence, stubbing it.

redefine_task :task_name => 'db:abort_if_pending_migrations', :desc => 'Override default pending migrations check' do
end

redefine_task :task_name => "db:test:purge", 
  :desc =>  "Empty the test database (DB2 supported version)" do
  abcs = ActiveRecord::Base.configurations
  case abcs["test"]["adapter"]
  when "ibm_db", "jdbcdb2"
    ActiveRecord::Base.establish_connection(:test)
    conn = ActiveRecord::Base.connection.connection
    begin
      # Required for the stored procedure ADMIN_DROP_SCHEMA
      ActiveRecord::Base.connection.execute("CREATE TABLESPACE SYSTOOLSPACE")
      systool_existing = false
    rescue
      # The SYSTOOLSPAGE already exists
      systool_existing = true
    end

    # Collects all the user defined schemas
    user_schemas_sql = "SELECT SCHEMANAME FROM SYSCAT.SCHEMATA WHERE DEFINER <> 'SYSIBM' AND \
	  SCHEMANAME NOT IN ('NULLID', 'ERRORSCHEMA', 'SYSTOOLS')"
    schemas = ActiveRecord::Base.connection.select_all(user_schemas_sql)

    unless schemas.empty?
      errortabschema = 'ERRORSCHEMA'
      errortab = 'ERRORTABLE'

      # Drop each schema and all its objects
      schemas.each do |schema|
        schema_name = schema["schemaname"].strip.upcase
        sql = "CALL SYSPROC.ADMIN_DROP_SCHEMA('#{schema_name}', NULL, ?, ?)"
        stmt = IBM_DB::prepare(conn, sql)  
        IBM_DB::bind_param(stmt, 1, "errortabschema", IBM_DB::SQL_PARAM_INPUT)
        IBM_DB::bind_param(stmt, 2, "errortab", IBM_DB::SQL_PARAM_INPUT)
        IBM_DB::execute(stmt)
      end

      # If the tablespace SYSTOOLSPACE didn't exist initially, it gets dropped  
      ActiveRecord::Base.connection.execute("DROP TABLESPACE SYSTOOLSPACE") unless systool_existing

      # Drops the remaining schema "ERRORSCHEMA"
      ActiveRecord::Base.connection.execute("DROP SCHEMA ERRORSCHEMA RESTRICT")
    end
  when "oci", "oracle", "jdbcoracle"
    ActiveRecord::Base.establish_connection(:test)
    user_view_sql = "SELECT view_name FROM USER_VIEWS"
    ActiveRecord::Base.connection.select_all(user_view_sql).each do |view|
      ActiveRecord::Base.connection.execute("drop view #{view.to_a.first.last}")
    end
  end
  if RUBY_PLATFORM =~ /java/
      db = ActiveRecord::Base.connection.database_name
      ActiveRecord::Base.connection.recreate_database(db) unless abcs["test"]["adapter"] == 'jdbcdb2'
  else
    Rake::Task[:original_test_purge].invoke unless abcs["test"]["adapter"] == 'ibm_db'
  end
end

redefine_task :task_name => "db:test:prepare", 
  :desc => 'Prepare the test database (Options are sql, schema.rb or migration)' do
  if defined?(ActiveRecord::Base) && !ActiveRecord::Base.configurations.blank?
    Rake::Task[{ :sql  => "db:test:clone_structure", :ruby => "db:test:clone", :migration => "db:test:migrate" }[ActiveRecord::Base.schema_format]].invoke
  end
end

namespace :db do
  namespace :test do
    desc 'Use the migrations to create the test database'
    task :migrate => 'db:test:purge' do
      begin
        ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])
        ActiveRecord::Migrator.migrate("db/migrate/")
      end
    end
  end
end

namespace :db do
  #we have faked the test environment, by copying the current environment as test environment,
  #so as to re-use the db:test:purge task available in rails and not have to copy it specific for
  #every environment
  desc "Fake dev env as test env"
  task :fake_test_env => :environment do
    ActiveRecord::Base.configurations['test'] = ActiveRecord::Base.configurations[RAILS_ENV || 'development']
  end

  desc 'Use the migrations to re create the database'
  task :remigrate => ['db:fake_test_env', 'db:test:purge'] do
    begin
      puts "***********new WAY"
      ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])
      ActiveRecord::Migrator.migrate("db/migrate/")
    end
  end
end

namespace :spec do
  namespace :db do
    namespace :test do
      namespace :fixtures do
        desc "Load fixtures into the current environment's database.  Load specific fixtures using FIXTURES=x,y"
        task :load => :environment do
          require 'active_record/fixtures'
          ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])
          (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir.glob(File.join(RAILS_ROOT, 'spec', 'fixtures', '*.{yml,csv}'))).each do |fixture_file|
            Fixtures.create_fixtures('spec/fixtures', File.basename(fixture_file, '.*'))
          end
        end
      end	
    end
  end
end
