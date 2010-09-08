# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'
require 'rspec_on_rails_hacks'

require 'lfs_matchers'
require File.expand_path(File.dirname(__FILE__) + "/../vendor/app_gems/validatable/lib/validatable")

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
  
  # 
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
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  # 
  # For more information take a look at Spec::Example::Configuration and Spec::Runner
end

# Presenter examples use Spec::Rails::Example::ModelExampleGroup, which
# provides support for fixtures and some custom expectations via extensions
# to ActiveRecord::Base.
Spec::Example::ExampleGroupFactory.register(:presenter, Spec::Rails::Example::ModelExampleGroup)


class SortInfoHolder
  
  def initialize
    @sort_data = []
  end
  
  def add_to_sortable_columns(sort_name, options = {})
    @sort_data << options.merge(:sort_name => sort_name)
  end
  
  def sortable_order(*args)
    
  end
  
  def sortable_column_header_data
    @sort_data
  end
end

def stub_user_login
  session[:user] = 'brenda'
  stub_current_user
end

class ActionController::TestRequest
  def user_preferred_languages
    ['en-US']
  end
end

def stub_current_user
  company_user = stub("company user", :user_id => 'brenda', :profile => stub("Profile", :has_role? => true), :user_profile => stub("User Profile"))
  company = stub("company", :company_id => "1", :company_users => stub("Company users", :find => company_user))
  user = stub("User", :user_id => 'brenda', :company => company, :companies => stub("Companies", :first => company, :find => company))

  User.stub!(:find_by_user_id).and_return(user)
  CompanyUser.stub!(:find_by_user_id).and_return(company_user)
  User.stub!(:current=).and_return(true)
  User.stub!(:current).and_return(user)
  Company.stub!(:current=).and_return(true)
  Company.stub!(:current).and_return(company)
  CompanyUser.stub!(:current).and_return(company_user)
end

def stub_set_system_parameters
  config = stub("Config", :date_formatter_string => '%Y-%m-%d', :date_time_formatter_string => '%Y-%m-%d %I:%M:%S %p')
  setting = stub("Setting", :currency_symbol => 'SGD', :negative_amount_style => "N")
  instance = stub("Cache-Instance", :account_display_setting => setting, :config => config )
  Cache.stub!(:instance).and_return(instance)
end

class ApplicationController
  
  # This filter should have been already available via plugin "dev authentication", "sortable_column_headers"
  # But it does appear that there is some issue with RSpec on Rails and this plugin loaded mechanism.
  # As a hack doing it here to get the spec running.
  
  before_filter :login_required
  before_filter :init_sortable_column_headers

end  

