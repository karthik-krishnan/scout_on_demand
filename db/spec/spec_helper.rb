# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'
require 'rspec_on_rails_hacks'
require 'lfs_matchers'

Spec::Runner.configure do |config|
    # If you're not using ActiveRecord you should remove these
    # lines, delete config/database.yml and disable :active_record
    # in your config/boot.rb
    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures  = false
    config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
    config.include LfsMatchers
    config.include Formatters

    table_name_class_name_map = generic_table_name_class_name_map
    config.fixture_classes = table_name_class_name_map
  
    fixtures_symbol_array = Dir.glob(File.join(RAILS_ROOT, 'spec', 'fixtures', '*.yml')).inject([]) do |result, fixture_file|
        fixture_as_symbol = File.basename(fixture_file, '.*').to_sym
        result << fixture_as_symbol
    end
    config.global_fixtures = fixtures_symbol_array

    # == Fixtures
    #
    # You can declare fixtures for each example_group like this:
    #   describe "...." do
    #     fixtures :table_a, :table_b
    #
    # Alternatively, if you prefer to declare them only once, you can
    # do so right here. Just uncomment the next line and replace the fixture
    # names with your fixtures.
    #
    # config.global_fixtures = :table_a, :table_b
    #
    # If you declare global fixtures, be aware that they will be declared
    # for all of your examples, even those that don't use them.
    #
    # == Mock Framework
    #
    # RSpec uses it's own mocking framework by default. If you prefer to
    # use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
  Spec::Runner
end
