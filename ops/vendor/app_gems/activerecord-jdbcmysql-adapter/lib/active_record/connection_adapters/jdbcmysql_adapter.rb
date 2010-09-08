require "jdbc_adapter"
require "jdbc/mysql"
require 'active_record/connection_adapters/jdbc_adapter'

module ActiveRecord
  class Base
    class << self
      alias_method :jdbcmysql_connection, :mysql_connection
    end
  end
end
