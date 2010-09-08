require 'active_record/fixtures'

module ActiveFixture
  
  @@active_fixture_fixtures_ordered_for_constraint_friendliness  = nil
  MODELS_PATH = "#{RAILS_ROOT}/app/models"
  YML_PATH = "#{RAILS_ROOT}/spec/fixtures"
  

  def self.make_constraint_friendly_ordered_fixture_List
    unless @@active_fixture_fixtures_ordered_for_constraint_friendliness.nil?
      return @@active_fixture_fixtures_ordered_for_constraint_friendliness
    end
    
    # grabbing the models file name & load the class
    table_names = list_referenced_tables
    graph = {}
    table_names.keys.each do |table_name|
      table = table_name
      graph[ table ] = Node.new( table ) 
    end
    graph.each do|key, node|
      a = table_names[key]
      a.each do |reference_table|
        node.add_edge( Edge.new( node, graph[ reference_table ] ) )
      end
    end
    # now traverse the graph to get the fixtures loading orders
    fixtures = []
    # sort the graph based on the number of foreign keys each node has
    # we'd load the fixture for nodes that have the least amount of edges first
    graph_nodes = graph.sort{ |a,b| a[1].edges.length <=> b[1].edges.length }
    graph_nodes.each do |graph_node|
      node = graph_node[1]       
      if !fixtures.include?( node )
        dfs = DFSTraversal.new()
        result = dfs.post_order_traverse( node )
        fixtures.concat( result )
      end
    end
    
    tables_with_fixtures = Dir["#{fixtures_dir}/*.yml"].collect {|f| File.basename(f, '.yml')}
    ordered_fixtures = fixtures.collect {|f| f.data}
  
    fixtures_filtered = []
    ordered_fixtures.each {|t| 
      #fixtures_filtered << t if tables_with_fixtures.any? {|f| f.upcase == t}
      tables_with_fixtures.each do |f| 
        fixtures_filtered << f if f.upcase == t.upcase
      end
    }  
    table_names = fixtures_filtered.uniq
    @@active_fixture_fixtures_ordered_for_constraint_friendliness = table_names
  end
  
  def self.fixtures_dir
    ENV['FIXTURES_DIR'] || 'spec/fixtures'
  end
  
  def self.list_referenced_tables
    #db_type = :mysql # Set the dbtype here Options are :db2, :oracle and :mysql

    db_type = if oracle?
      :oracle
    elsif db2?
      :db2
    elsif mysql?
      :mysql
    else  
      raise "unrecognized database"
    end   
    
    database_name = ActiveRecord::Base.connection.select_one('select database()') if mysql?
    case db_type
    when :oracle
      fetch_all_tables_sql = "SELECT table_name FROM USER_TABLES ORDER BY table_name"
      fetch_fk_tables_sql = "SELECT table_name FROM USER_CONSTRAINTS WHERE constraint_type in ('U', 'P') AND constraint_name IN (SELECT r_constraint_name FROM USER_CONSTRAINTS WHERE constraint_type = 'R' AND table_name = '__table_name__')"
    when :db2
      fetch_all_tables_sql = "SELECT tabname as table_name FROM syscat.tables WHERE OWNER <> 'SYSIBM'"
      fetch_fk_tables_sql = "SELECT reftabname as table_name FROM syscat.references WHERE tabname = '__table_name__'"
    when :mysql
      database_name = ActiveRecord::Base.connection.select_one('select database()')
      fetch_all_tables_sql = "SELECT table_name FROM information_schema.tables where table_schema = '#{database_name['database()']}'"
      fetch_fk_tables_sql = "SELECT referenced_table_name as table_name FROM information_schema.KEY_COLUMN_USAGE K WHERE constraint_schema = '#{database_name['database()']}' AND 
                                referenced_table_name IS NOT NULL AND table_name = '__table_name__'"
    end
    
    t_names = {}
    table_names = ActiveRecord::Base.connection.select_all(fetch_all_tables_sql)
      table_names.each do |table_name|
      sql = fetch_fk_tables_sql.gsub("__table_name__","#{table_name['table_name']}" )
      fk_tables = ActiveRecord::Base.connection.select_all(sql)
      fk_table = []
      fk_tables.each do |f_table|
        fk_table << f_table['table_name'] unless  f_table['table_name'] == table_name['table_name']
      end
      t_names[table_name['table_name']] =  fk_table
    end
    t_names
  end

  
  # Node represents a node in the graph
  class Node < Struct.new( :edges, :data )
    attr_accessor :visited, :edges, :data
    
    def initialize( data )
      self.data = data
      self.edges = []
      self.visited = false
    end
    
    def add_edge( edge )
      self.edges << edge
    end
    
    # used to debug 
    def to_s
      "[Node]" << self.data << "[" << self.edges.collect{ |edge| edge.to_node.data }.join(",") << "]"
    end
    
    # used by Array.include?
    # We only need to compare the data (containing the mode) since we know each model is associated with only 1 node.
    def ==(other)
      return self.data == other.data
    end
  end
  
  # Edge represents a direct relationship between 2 nodes
  class Edge < Struct.new( :from_node, :to_node )
    def initialize( from_node, to_node )
      self.from_node = from_node
      self.to_node = to_node
    end
  end
  
  # Main algorithm class to traverse the graph
  # Reference:  http://en.wikipedia.org/wiki/Depth-first_search
  class DFSTraversal < Struct.new( :visited )
    
    def initialize
      self.visited = []
    end
    
    # traversing the graph
    def post_order_traverse( node )
      self._post_order_traverse( node )
      return self.visited
    end

    # private method to do the actual traversing
    def _post_order_traverse( node )
      node.edges.each do |edge| 
        self._post_order_traverse( edge.to_node ) if !edge.to_node.visited
      end
      node.visited = true
      self.visited << node
    end
  end  
  
end # module

module MoreFixtureAdditions
  module ClassMethods

    def create_fixtures_with_constraint_order(fixtures_directory, table_names, class_names = {})
      table_names_to_fetch = ActiveFixture.make_constraint_friendly_ordered_fixture_List
      connection = block_given? ? yield : ActiveRecord::Base.connection
      fixtures = create_fixtures_without_constraint_order( fixtures_directory, table_names_to_fetch, 
        class_names) {connection}
    end
  end
  
  def self.included base
    base.extend ClassMethods
    base.class_eval do 
      class << self
        alias_method_chain :create_fixtures, :constraint_order
      end
    end
  end
end

class ::Fixtures
  include MoreFixtureAdditions
end
