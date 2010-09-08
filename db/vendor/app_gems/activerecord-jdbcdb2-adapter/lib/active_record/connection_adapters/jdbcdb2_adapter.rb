require "jdbc_adapter"
require "jdbc/db2"
require 'active_record/connection_adapters/jdbc_adapter'

module ActiveRecord
  class Base
    class << self
      alias_method :jdbcdb2_connection, :jdbc_connection
    end
  end
end
