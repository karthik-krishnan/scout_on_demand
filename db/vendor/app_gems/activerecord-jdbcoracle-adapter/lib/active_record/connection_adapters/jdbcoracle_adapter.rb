require "jdbc_adapter"
require "jdbc/oracle"
require 'active_record/connection_adapters/jdbc_adapter'

module ActiveRecord
  class Base
    class << self
      alias_method :jdbcoracle_connection, :oracle_connection
    end
  end
end
