# SoftFixtures
require 'fileutils'

class Object
  def scenario(scenario, &block)
    case scenario
    when Hash
      SoftFixturesBuilder.register_scenario(scenario.keys.first, block, scenario.values.first)
    when Symbol
      SoftFixturesBuilder.register_scenario(scenario, block)
    end
  end
    
  def build_scenario(scenario, should_dump_tables = true)
    if scenario.nil?
      raise "No Scenario specified"
    end
    scenario = scenario.to_sym
    SoftFixturesBuilder.new(scenario).build(should_dump_tables)
  end
end


class SoftFixturesBuilder
  cattr_accessor :scenarios_details
  self.scenarios_details = {}
  @@record_name_fields = %w( name title username login )
  @@table_names_and_row_index = {}
  @@refresh_required ||= true
  @@delete_sql = "DELETE FROM %s"
  @@select_sql = "SELECT * FROM %s"

  def self.register_scenario(scenario, block, parent = nil)
    @@scenarios_details[scenario] = {:block => block, :parent => parent}
  end
    
  def self.validate_scenario(scenario)
    raise "I don't know how to build #{scenario}" unless @@scenarios_details.keys.include?(scenario)
  end
    
  def self.get_scenario(scenario)
    validate_scenario(scenario)
    @@scenarios_details[scenario][:parent]
  end
    
  def self.get_scenario_parent(scenario)
    validate_scenario(scenario)
    @@scenarios_details[scenario][:parent]
  end
    
  def self.get_scenario_block(scenario)
    validate_scenario(scenario)
    @@scenarios_details[scenario][:block]
  end
    
  def initialize(scenario)
        
    self.class.validate_scenario scenario
    @block = self.class.get_scenario_block(scenario)
    raise NoMethodError, "undefined method `scenario' for #{inspect}" if @block.nil?
    @parent = self.class.get_scenario_parent(scenario)
    @scenario = scenario.to_s
    @custom_names = {}
  end

  def say(*messages)
    puts messages.map { |message| "=> #{message}" }
  end

  def build(should_dump_tables = true)
    if @parent
      build_scenario(@parent, false)
    end
    #return if fixtures_dir_exists? unless rebuild_fixtures?
    say "Building scenario `#{@scenario}'"
    refresh_database if refresh_required? #delete_tables
    surface_errors { instance_eval(&@block) }
    if (should_dump_tables)
      #FileUtils.rm_rf   fixtures_dir(@scenario) if rebuild_fixtures?
      FileUtils.rm Dir.glob("#{fixtures_dir(@scenario)}/*.yml") if rebuild_fixtures?
      FileUtils.mkdir_p fixtures_dir(@scenario)
      dump_tables
    end
  end

  def refresh_required?
    @@refresh_required
  end
  
  def surface_errors
    yield
  rescue Object => error
    puts
    say "There was an error building scenario '#{@scenario}'", error.inspect
    puts
    puts error.backtrace
    puts
    exit!
  end

  def refresh_database
    if RUBY_PLATFORM =~ /java/
      `jruby -S rake db:remigrate`
    else
      `rake db:remigrate`
    end
    @@refresh_required = false
  end
  
  def delete_tables
    ActiveRecord::Base.connection.tables.each { |t| ActiveRecord::Base.connection.delete(@@delete_sql % t)  }
  end

  def tables
    ActiveRecord::Base.connection.tables - skip_tables
  end

  def skip_tables
    #venkat Nov 19, 2009
    #sym_trigger is a SymmetricDS related table and hence better to be ignored.
    #A better solution would be to allow an app to give its own list of exceptions
    %w( schema_info schema_migrations sym_trigger)
  end
  
  def name(custom_name, model_object)
    key = [model_object.class.name, model_object.id]
    @custom_names[key] = custom_name
    model_object
  end
  
  def names_from_ivars!
    instance_values.each do |var, value|
      name(var, value) if value.is_a? ActiveRecord::Base
    end
  end

  def record_name(record_hash)
    key = [@table_name.classify, record_hash['id'].to_i]
    @record_names << (name = @custom_names[key] || inferred_record_name(record_hash) )
    name
  end
  
  def inferred_record_name(record_hash)
    @@record_name_fields.each do |try|
      if name = record_hash[try]
        inferred_name = name.underscore.gsub(/\W/, ' ').squeeze(' ').tr(' ', '_')
        count = @record_names.select { |name| name == inferred_name }.size
        return count.zero? ? inferred_name : "#{inferred_name}_#{count}"
      end
    end

    "#{@table_name}_#{@row_index.succ!}"
  end

  def dump_tables
    fixtures = tables.inject([]) do |files, @table_name|
      next files if fixture_file_exists? unless rebuild_fixtures?

      rows = ActiveRecord::Base.connection.select_all(@@select_sql % @table_name)

      @@table_names_and_row_index[@table_name] ||=  '000'
      @row_index = @@table_names_and_row_index[@table_name]
      @record_names = []
      fixture_data = rows.empty? ? nil : rows.inject({}) { |hash, record| hash.merge(record_name(record) => record) }

      write_fixture_file fixture_data

      files + [File.basename(fixture_file)]
    end

    say "Built scenario '#{@scenario}' with #{fixtures.to_sentence}"
  end

  def write_fixture_file(fixture_data)
    File.open(fixture_file, 'w') do |file|
      yaml_out = fixture_data.to_yaml
      file.write yaml_out[5..yaml_out.length]
    end
  end

  def fixture_file
    fixtures_dir(@scenario, "#{@table_name}.yml")
  end

  def fixtures_dir(*paths)
    fixtures_folder = ENV['FIXTURES_DIR'] || File.join(RAILS_ROOT, 'scenarios')
    File.join(fixtures_folder, *paths)
  end
  
  def fixtures_dir_exists?(dir = @scenario)
    File.exists? fixtures_dir(dir)
  end

  def fixture_file_exists?
    File.exists? fixture_file
  end

  def rebuild_fixtures?
    true #scenarios_file_changed?
  end

  def scenarios_file_changed?
    can_trigger_rebuild = [
      fixtures_dir('scenarios.rb'),
      File.join(RAILS_ROOT, 'db', 'migrate'),
      File.join(RAILS_ROOT, 'db', 'example_data.rb')
    ]

    can_trigger_rebuild.any? { |file| older_than_scenario? file }
  end

  def older_than_scenario?(file)
    scenario_dir = fixtures_dir(@scenario)
    if File.exists?(file) && File.exists?(scenario_dir)
      File.mtime(file) > File.mtime(scenario_dir)
    end
  end
end
