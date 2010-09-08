namespace :lfs do
  namespace :fixtures do
    desc "(Works with DB2 as well)Load fixtures (from spec/fixtures) into the current environment's database.  Load specific fixtures using FIXTURES=x,y"
    task "fk_constraint_supported_fixtures_load" => :environment do
      fixtures_dir = ENV['FIXTURES_DIR'] || 'spec/fixtures'
      require 'active_record/fixtures'
      ENV['ENVIRONMENT'] ||= ENV['RAILS_ENV']
      ActiveRecord::Base.establish_connection( ENV['ENVIRONMENT'] )
      all_tables_with_fixtures = Dir.glob(File.join(fixtures_dir, '*.yml')).inject([]) do |result, fixture_file|
        result << File.basename(fixture_file, '.*')
      end
      Fixtures.create_fixtures(fixtures_dir, all_tables_with_fixtures , generic_table_name_class_name_map )
    end
    
    desc "(Works with DB2 as well)Load fixtures (from spec/fixtures) into the current environment's test database.  Load specific fixtures using FIXTURES=x,y"
    task "fk_constraint_supported_test_fixtures_load" => :environment do
      ENV['ENVIRONMENT'] = 'test'
      Rake::Task['lfs:fixtures:fk_constraint_supported_fixtures_load'].invoke
    end    
  end
end

