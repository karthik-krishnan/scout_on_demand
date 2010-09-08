MYSQL, ORACLE, DB2 = 'mysql', 'oracle', 'db2'
ENV['db'] = MYSQL
GLASSFISH_HOME=''
ENV['DOMAIN_DIR'] ||= "#{ENV['HOME']}/workspace/gfdomains"
HOST_IP = 'localhost'
ORACLE_SERVER_NAME = 'swami'
ORACLE_APP_USER_NAME = 'scout'
ORACLE_APP_USER_PWD = 'scout'
ORACLE_SSO_USER_NAME = 'scout_sso'
ORACLE_SSO_USER_PWD = 'scout_sso'

CLUSTER_NAME = "scout_cluster"
JMX_SYSTEM_CONNECTOR_PORT=8687
IIOP_LISTENER_PORT=3330
IIOP_SSL_LISTENER_PORT=4440
IIOP_SSL_MUTUALAUTH_PORT=5550
HTTP_LISTENER_PORT=1110
HTTP_SSL_LISTENER_PORT=2220


ENV['MYSQL_SCOUT_DB_NAME']= 'scout'
ENV['MYSQL_SSO_DB_NAME']= 'scout_sso'
ENV['DOMAIN_NAME'] = 'scout'

ROOT_FOLDER = File.expand_path(File.dirname(__FILE__))

task :default => [:prepare_db, :setup_domain, :configure_cluster_if_enabled, :configure, :deploy]
task :setup_demo => [:prepare_demo_db, :setup_domain, :configure, :deploy]
task :configure => [:prepare_env_properties, :update_db_configuration]
task :configure_cluster => [:create_cluster, :create_node_agents_and_instances]

task :configure_cluster_if_enabled do
  Rake::Task['configure_cluster'].invoke if cluster_enabled?
end

task :configure_for_jboss => [:prepare_db, :configure, :prepare_for_jboss_deployment]

task :deploy => [:create_jdbc_data_sources, :deploy_app_modules]

task :integration_testing => [:default, :prepare_demo_db]

desc "Deploy Demo Application"
task :demo do
  ENV['server_name']='scoutdemo'
  ENV['port_base']='2000'
  ENV['MYSQL_SCOUT_DB_NAME']= "demo_scout"
  ENV['MYSQL_SSO_DB_NAME']= "demo_scout_sso"
  ENV['DOMAIN_NAME'] = 'scoutdemo'
  Rake::Task['setup_demo'].invoke
end

desc "Load Demo Data"
task :load_demo_data do
    print "Loading Application Fixtures..."
    Dir.chdir("db_migrations") do
      run_rake_task "db:soft_fixtures:build SCENARIO=test"
      run_rake_task "lfs:fixtures:fk_constraint_supported_fixtures_load FIXTURES_DIR=scenarios/test"
    end
    puts "done."

end

desc "Prepare Demo Database..."
task :prepare_demo_db => [:prepare_db, :load_demo_data]

desc "Prepare Database..."
task :prepare_db do
  mysql_app_db_props = {'development' => {
      'adapter' => 'jdbcmysql',
      'database' => ENV['MYSQL_SCOUT_DB_NAME'],
      'encoding' => 'utf8',
      'username' => 'root',
      'password' => nil,
      'host' => '127.0.0.1'
    }
  }

  oracle_app_db_props = {'development' => {
      'adapter' => 'jdbcoracle',
      'username' => "#{ORACLE_APP_USER_NAME}",
      'password' => "#{ORACLE_APP_USER_PWD}",
      'host' => "#{HOST_IP}",
      'database' => "#{ORACLE_SERVER_NAME}",
    }
  }

  mysql_sso_db_props = {'development' => {
      'adapter' => 'jdbcmysql',
      'database' => ENV['MYSQL_SSO_DB_NAME'],
      'encoding' => 'utf8',
      'username' => 'root',
      'password' => nil,
      'host' => '127.0.0.1'
    }
  }

  oracle_sso_db_props = {'development' => {
      'adapter' => 'jdbcoracle',
      'username' => "#{ORACLE_SSO_USER_NAME}",
      'password' => "#{ORACLE_SSO_USER_PWD}",
      'host' => "#{HOST_IP}",
      'database' => "#{ORACLE_SERVER_NAME}",
    }
  }

  print "Preparing Application Database..."
  Dir.chdir("db_migrations") do
    require 'yaml'
    if db_vendor == MYSQL
      db_props = mysql_app_db_props
    elsif db_vendor == ORACLE
      db_props = oracle_app_db_props
    end
    File.open('config/database.yml', 'w') { |f| f.puts db_props.to_yaml }
    run_rake_task "db:migrate"
    puts "done."
  end
end

def db_vendor
  ENV['db'] || MYSQL
end

def port_base
  ENV['port_base'] || '3000'
end

def gf_admin_port
  (port_base.to_i + 48).to_s
end

def gf_http_port
  (port_base.to_i + 80).to_s
end

def server_name
  ENV['server_name'] || `ifconfig`.scan(/inet addr:([\d\.]+)/)[0][0]
end

def asadmin_cmd(cmd_line, admin_user = 'admin', admin_port = gf_admin_port , success_message = "#{cmd_line} ran successfully", reg_exp = /successfully/ )
  cmd_line =~ /^([\w\-]+)/
  cmd_name = $1
  cmd_to_running_server = true
  cmd_to_running_server = ['create-domain','start-domain', 'stop-domain'].include?(cmd_name) ? false : true
  derived_cmd_line = if cmd_to_running_server
    "asadmin  " + cmd_line.gsub(cmd_name, cmd_name + " -p " + admin_port + ' --user ' + admin_user + " --passwordfile ./pwd.txt")
  else
    "asadmin  " + cmd_line.gsub(cmd_name, cmd_name + " --domaindir #{ENV['DOMAIN_DIR']}")
  end
  p "Running: " + derived_cmd_line
  result = `#{derived_cmd_line}`
  if result =~ reg_exp
    puts success_message
    true
  else
    puts result
    false
  end
end

def create_connection_pool(pool_name, url, user, password)
  if db_vendor == MYSQL
    data_source_class_name = 'com.mysql.jdbc.jdbc2.optional.MysqlDataSource'
  elsif db_vendor == ORACLE
    data_source_class_name = 'oracle.jdbc.pool.OracleDataSource'
  end
  user ||= 'prod_root'
  password ||= 'prod_root'
  resource_type = 'javax.sql.DataSource'
  url.gsub!(/:/, '\:').gsub!(/=/,'\=')
  asadmin_cmd "create-jdbc-connection-pool --datasourceclassname #{data_source_class_name} --isconnectvalidatereq=true --restype #{resource_type} --property user=#{user}:password=#{password}:url=\"#{url}\" #{pool_name}"
end

def create_mysql_connection_pool(pool_name, db_schema_name, db_user, db_password)
  create_connection_pool pool_name, "jdbc:mysql://#{HOST_IP}/#{db_schema_name}?useUnicode=true&characterEncoding=UTF-8", db_user, db_password
end

def create_oracle_connection_pool(pool_name, db_user, db_password, host_ip = HOST_IP, server_name = ORACLE_SERVER_NAME)
  create_connection_pool pool_name, "jdbc:oracle:thin:@#{host_ip}:1521:#{server_name}", db_user, db_password
end

def delete_connection_pool(pool_name)
  asadmin_cmd "delete-jdbc-connection-pool #{pool_name}"
end

def create_data_source(data_source_name, pool_name)
  params = (cluster_enabled? ? " --target #{CLUSTER_NAME}" : "")
  asadmin_cmd "create-jdbc-resource #{params} --connectionpoolid #{pool_name} #{data_source_name}"
end

def delete_data_source(data_source_name)
  asadmin_cmd "delete-jdbc-resource #{data_source_name}"
end

def deploy_app(file_name, component_name = nil, context_root = nil, availability = true)
  params = ''
  params += (component_name.nil? ? '' : " --name \"#{component_name}\"")
  params += (context_root.nil? ? '' : " --contextroot #{context_root}")
  params += (availability ? " --availabilityenabled=true" : " ")
  params += (cluster_enabled? ? " --target #{CLUSTER_NAME}" : " ")
  asadmin_cmd "deploy #{params} #{file_name}"
end

def undeploy_app(component_name)
  asadmin_cmd "undeploy #{component_name}"
end

def process_erb_template(template_file_path, params)
  require 'erb'
  template = IO.readlines(template_file_path)
  @params = params
  file_path = File.join(File.dirname(template_file_path), File.basename(template_file_path, ".template"))
  web_xml_output = ERB.new(template, 0, "%<>")
  File.open(file_path, 'w') {|file|
    file.puts web_xml_output.result
  }
end

def update_database_yml_for_war(war_file_path, params)
  print "Updating DB configuration for #{war_file_path}..."
  rm_rf "./tmp"
  mkdir_p "./tmp"
  `unzip #{war_file_path} WEB-INF/config/database.yml.template -d ./tmp/`
  Dir.chdir("./tmp") do
    process_erb_template('./WEB-INF/config/database.yml.template', params)
  end
  `jar -uvf #{war_file_path} -C ./tmp .`
  puts "done."
  rm_rf "./tmp"
end

def update_web_xml_and_environment_property_for_war(war_file_path, params, environment_properties_path)
  print "Updating SSO configuration for #{war_file_path}..."
  rm_rf "./tmp"
  mkdir_p "./tmp"
  `unzip #{war_file_path} WEB-INF/web.xml.template WEB-INF/#{environment_properties_path}/ -d ./tmp/`

  Dir.chdir("./tmp") do
    process_erb_template('./WEB-INF/web.xml.template', params)
  end
  `cp ./environment.properties ./tmp/WEB-INF/#{environment_properties_path}/`
  `jar -uvf #{war_file_path} -C ./tmp .`
  puts "done."
  rm_rf "./tmp"
end

def properties_to_hash(properties_file_location)
  properties = {}
  File.exists?(properties_file_location) && File.open(properties_file_location, 'r') do |properties_file|
    properties_file.read.each_line do |line|
      line.strip!
      if (line[0] != ?# and line[0] != ?=)
        i = line.index('=')
        if (i)
          properties[line[0..i - 1].strip] = line[i + 1..-1].strip
        else
          properties[line] = ''
        end
      end
    end
  end
  properties
end

def hash_to_properties(hash, properties_file_location)
  File.open(properties_file_location, "w") do |file|
    hash.each_pair {|key, value|
      file.puts("#{key}=#{value}")
    }
  end
end

desc "Update DB Configuration"
task :update_db_configuration do
  params = {}
  params[:db] = db_vendor.to_sym
  update_database_yml_for_war('ops.war', params)
end

desc "Update SSO Configuration"
task :update_sso_configuration do
  raise "ERROR : environment.properties is missing in the current folder. Please recheck it." unless File.exists?('./environment.properties')
  props = properties_to_hash("./environment.properties")
  update_web_xml_and_environment_property_for_war('ops.war', props, "config")
  update_web_xml_and_environment_property_for_war('mc.war', props, "config")
  update_web_xml_and_environment_property_for_war('sso_admin.war', props, "config")
  update_web_xml_and_environment_property_for_war('txn_auth.war', props, "classes")
end

desc "Preparing environment properties"
task :prepare_env_properties do
  unless File.exists?("./environment.properties")
    `cp ./environment.properties.example ./environment.properties`
  end
end

desc "Update SSO Configuration for current host"
task :auto_update_sso_configuration do
  should_delete_env_file = false
  unless File.exists?("./environment.properties")
    `cp ./environment.properties.example ./environment.properties`
    should_delete_env_file = true
    props = properties_to_hash("./environment.properties")
    props["application.base_url"] = "http://#{server_name}:#{gf_http_port}"
    props["application.internal_base_url"] = "http://#{server_name}:#{gf_http_port}"
    props["sso_server.base_url"] = "http://#{server_name}:#{gf_http_port}"
    props["sso_server.internal_base_url"] = "http://#{server_name}:#{gf_http_port}"
    hash_to_properties(props, "./environment.properties")
  end
  Rake::Task['update_sso_configuration'].invoke
  `rm ./environment.properties` if should_delete_env_file
end

desc "Setup GlassFish Domain"
task :setup_domain do
  `echo \"AS_ADMIN_MASTERPASSWORD=changeit\" > pwd.txt`
  `echo \"AS_ADMIN_PASSWORD=adminadmin\" >> pwd.txt`
  p "Removing domain if exists"
  if File.exists?(ENV['DOMAIN_DIR'] + '/' + ENV['DOMAIN_NAME'])
    asadmin_cmd "stop-domain " + ENV['DOMAIN_NAME']
    `rm -rf #{ENV['DOMAIN_DIR']}/#{ENV['DOMAIN_NAME']}`
  end
  p "Creating " + ENV['DOMAIN_NAME'] + " domain..."
  #profile = cluster_enabled
  asadmin_cmd "create-domain --profile #{gf_profile} --portbase #{port_base} --user admin --passwordfile ./pwd.txt " + ENV['DOMAIN_NAME']
  cp_r (Dir.glob('lib/*.jar') - ["lib/jruby-complete.jar"]), "#{ENV['DOMAIN_DIR']}/#{ENV['DOMAIN_NAME']}/lib/ext"
  p "Starting #{ENV['DOMAIN_NAME']} domain..."
  asadmin_cmd "start-domain --user admin --passwordfile ./pwd.txt #{ENV['DOMAIN_NAME']}"
  asadmin_cmd "delete-jvm-options \\\\-client"
  asadmin_cmd "create-jvm-options \\\\-server"
  unless cluster_enabled?
    asadmin_cmd "delete-jvm-options \\\\-Xmx512m"
    asadmin_cmd "create-jvm-options \\\\-Xmx800m"
  end
  asadmin_cmd "create-jvm-options -Dlog4j.repositorySelector=JNDI"
  asadmin_cmd "create-jvm-options -DLogDir=../logs"
  asadmin_cmd "create-jvm-options -Djruby.compile.mode=OFF"
  asadmin_cmd "create-jvm-options -Djava.net.preferIPv4Stack=true"
  asadmin_cmd "create-jvm-options -Dhttp_listen_port=#{gf_admin_port}" #System property required for customized CAS SSO
  asadmin_cmd "stop-domain #{ENV['DOMAIN_NAME']}"
  asadmin_cmd "start-domain --user admin --passwordfile ./pwd.txt #{ENV['DOMAIN_NAME']}"
  asadmin_cmd "set server.http-service.property.accessLoggingEnabled=true"
  asadmin_cmd "create-jvm-options -Dcom.sun.enterprise.connectors.system.enableAutoClustering=false"
  if db_vendor == MYSQL
    create_mysql_connection_pool "scout_pool", ENV['MYSQL_SCOUT_DB_NAME'], 'prod_root', 'prod_root'
  elsif db_vendor == ORACLE
    create_oracle_connection_pool "scout_pool", ORACLE_APP_USER_NAME, ORACLE_APP_USER_PWD
  end
end

desc "Create JDBC Data Sources"
task :create_jdbc_data_sources do
  create_data_source "jdbc/scout", "scout_pool"
end

desc "Deploy Apps"
task :deploy_app_modules do
  deploy_app './ops.war', "ops_application", "ops"
end

desc "Prepare for JBoss Deployment"
task :prepare_for_jboss_deployment do
	`zip -d sso.war WEB-INF/lib/xalan*.jar WEB-INF/lib/xml*.jar WEB-INF/lib/xerces*.jar WEB-INF/lib/servlet-api*.jar`
	`zip -d sso2.war WEB-INF/lib/xalan*.jar WEB-INF/lib/xml*.jar WEB-INF/lib/xerces*.jar WEB-INF/lib/servlet-api*.jar`
  `zip -d ops.war WEB-INF/lib/drools-persistence*.jar`
  `zip -d mc.war WEB-INF/lib/drools-persistence*.jar`
end

desc "Creating Cluster"
task :create_cluster do
    asadmin_create_cluster CLUSTER_NAME
    asadmin_cmd "set #{CLUSTER_NAME}.http-service.property.accessLoggingEnabled=true"
    asadmin_cmd "delete-jvm-options --target #{CLUSTER_NAME} \\\\-client"
    asadmin_cmd "create-jvm-options --target #{CLUSTER_NAME} \\\\-server"
    asadmin_cmd "delete-jvm-options --target #{CLUSTER_NAME} \\\\-Xmx512m"
    asadmin_cmd "create-jvm-options --target #{CLUSTER_NAME} \\\\-Xmx1356m"
    asadmin_cmd "create-jvm-options --target #{CLUSTER_NAME} -Dlog4j.repositorySelector=JNDI"
    asadmin_cmd "create-jvm-options --target #{CLUSTER_NAME} -DLogDir=../logs"
    asadmin_cmd "create-jvm-options --target #{CLUSTER_NAME} -Djruby.compile.mode=OFF"
    asadmin_cmd "create-jvm-options --target #{CLUSTER_NAME} -Djava.net.preferIPv4Stack=true"
    asadmin_cmd "create-jvm-options --target #{CLUSTER_NAME} -Dhttp_listen_port=\\${HTTP_LISTENER_PORT}" #System property required for customized CAS SSO Client.
    asadmin_cmd "create-jvm-options --target #{CLUSTER_NAME} -Dcom.sun.enterprise.connectors.system.enableAutoClustering=false"
end

desc "Create Node Agents and Instances"
task :create_node_agents_and_instances do
  agents = node_agents_and_instances_info
  instance_index = 1
  agents.each {|agent_info|
    agent_name, instances = agent_info
    asadmin_create_node_agent_config agent_name
    instances.times {|index|
      system_props = "JMX_SYSTEM_CONNECTOR_PORT=#{JMX_SYSTEM_CONNECTOR_PORT+index}"
      system_props += ":IIOP_LISTENER_PORT=#{IIOP_LISTENER_PORT+index}"
      system_props += ":IIOP_SSL_LISTENER_PORT=#{IIOP_SSL_LISTENER_PORT+index}"
      system_props += ":IIOP_SSL_MUTUALAUTH_PORT=#{IIOP_SSL_MUTUALAUTH_PORT+index}"
      system_props += ":HTTP_LISTENER_PORT=#{HTTP_LISTENER_PORT+index}"
      system_props += ":HTTP_SSL_LISTENER_PORT=#{HTTP_SSL_LISTENER_PORT+index}"
      asadmin_create_instance(CLUSTER_NAME, agent_name, "instance-#{instance_index}", system_props)
      instance_index += 1
    }
  }
end

def run_rake_task(arg)
  `java -jar #{ROOT_FOLDER}/lib/jruby-complete.jar -S rake #{arg}`
end

def cluster_admin_host
  get_key_value("cluster.admin.host")
end

def cluster_admin_port
  get_key_value("cluster.admin.port")
end

def cluster_enabled?
  get_key_value("cluster.enabled")
end

def gf_profile
  cluster = cluster_enabled?
	if cluster == "true"
		domain_profile = "cluster"
	else
		domain_profile = "developer"
	end
  return domain_profile
end


def node_agents_count
  a = get_key_value("cluster.nodeagents").to_i
  puts "Total Node Agents = #{a}"
  a
end

def node_agents_and_instances_info
  agents = []
  node_agents_count.times {|index|
    agent_name =  get_key_value("cluster.nodeagent.#{index+1}")
    instances_count = get_key_value("cluster.nodeagent.#{index+1}.instances").to_i
    agents << [agent_name, instances_count]
  }
  agents
end

def get_key_value(key)
   props = properties_to_hash("./environment.properties")
   return props["#{key}"]
end

def create_cluster_instance(cluster, nodeagent, jmx_sys_conn_port, iiop_lsnr_port, iiop_ssl_lsnr_port, iiop_ssl_mauth_port, http_lsnr_port, http_ssl_lsnr_port)

   create_instance = " --cluster  #{cluster}   --nodeagent #{nodeagent}   --systemproperties 'JMX_SYSTEM_CONNECTOR_PORT=#{jmx_sys_conn_port}:IIOP_LISTENER_PORT=#{iiop_lsnr_port}:IIOP_SSL_LISTENER_PORT=#{iiop_ssl_lsnr_port}:IIOP_SSL_MUTUALAUTH_PORT=#{iiop_ssl_mauth_port}:HTTP_LISTENER_PORT=#{http_lsnr_port}:HTTP_SSL_LISTENER_PORT=#{http_ssl_lsnr_port}' "

end

def asadmin_create_cluster(cluster_name)
  cmd = "asadmin create-cluster --host #{cluster_admin_host} --user admin \
    --passwordfile ./pwd.txt --port #{cluster_admin_port} #{cluster_name}"
  run_cmd cmd
end

def asadmin_create_instance(cluster_name, node_agent_name, instance_name, system_properties)
  cmd = "asadmin create-instance --cluster #{cluster_name} --nodeagent #{node_agent_name} --systemproperties '#{system_properties}' \
    --host #{cluster_admin_host} --user admin \
    --passwordfile ./pwd.txt --port #{cluster_admin_port} #{instance_name}"
  run_cmd cmd
end

def asadmin_create_node_agent_config(agent_name)
  cmd = "asadmin create-node-agent-config --host #{cluster_admin_host} --user admin \
     --passwordfile ./pwd.txt --port #{cluster_admin_port} #{agent_name}"
  run_cmd cmd
end

def run_cmd(cmd)
  result = `#{cmd}`
  if result =~ /successfully/
    puts "#{cmd} ran successfully"
    true
  else
    puts result
     false
  end
end

def asadmin_cluster(cmd_line, admin_user = 'admin', admin_port = cluster_admin_port, host = cluster_admin_host, success_message = "#{cmd_line} ran successfully", reg_exp = /successfully/ )

  cmd_line =~ /^([\w\-]+)/
  cmd_name = $1

  cmd_to_running_server = true
  cmd_to_running_server = ['create-cluster','create-node-agent-config', 'create-instance', 'start-cluster'].include?(cmd_name) ? false : true

  derived_cmd_line = if cmd_name == "create-cluster"
  	"asadmin " + cmd_line.gsub(cmd_name, cmd_name + ' --user ' + admin_user + ' --passwordfile ./pwd.txt --port ' + admin_port + ' --host ' + host )
  elsif cmd_name == "create-node-agent-config"

  	"asadmin " + cmd_line.gsub(cmd_name, cmd_name + ' --user ' + admin_user + " --passwordfile ./pwd.txt --port " + admin_port + " --host "  )
  elsif cmd_name == "create-instance"
	"asadmin " + cmd_line.gsub(cmd_name, cmd_name + ' --user ' + admin_user + ' --passwordfile ./pwd.txt --host ' + host + ' --port ' + admin_port )
  elsif cmd_name == "start-cluster"
   "asadmin " + cmd_line.gsub(cmd_name, cmd_name + ' --user ' + admin_user + ' --passwordfile ./pwd.txt --port ' + admin_port + ' --host ' + host )
  end
  puts derived_cmd_line
  result = `#{derived_cmd_line}`
  if result =~ reg_exp
    puts success_message
    true
  else
    puts result
     false
  end
end


