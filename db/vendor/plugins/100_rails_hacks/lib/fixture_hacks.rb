require 'active_record/fixtures'
module FixtureHacks
  module ClassMethods

    def create_fixtures_with_disabled_constraints(fixtures_directory, table_names, class_names = {})
      connection = block_given? ? yield : ActiveRecord::Base.connection
      disable_integrity_constraints(connection)
      fixtures = create_fixtures_without_disabled_constraints( fixtures_directory, table_names, class_names) {connection}
      enable_integrity_constraints(connection)
      fixtures
    end
  
    def disable_integrity_constraints(connection)
      connection.update("SET FOREIGN_KEY_CHECKS=0") if connection.adapter_name =~ /MySQL/
    end

    def enable_integrity_constraints(connection)
      connection.update("SET FOREIGN_KEY_CHECKS=1") if connection.adapter_name =~ /MySQL/
    end

  end

  def self.included base
    base.extend ClassMethods
    base.class_eval do 
      class << self
        alias_method_chain :create_fixtures, :disabled_constraints
      end
    end
  end
end


class Fixtures
  include FixtureHacks
end
