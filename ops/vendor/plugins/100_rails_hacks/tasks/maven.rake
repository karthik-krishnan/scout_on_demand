      require 'fileutils'

class MavenLibraryMirror
    
      include FileUtils
    attr_accessor :artifact, :version, :locations
    
    def initialize(group, artifact, version, type='jar')
      @maven_local_repository = ENV['MAVEN2_REPO'] # should be in settings.xml, but I need an override
    	@maven_remote_repository = 'http://www.ibiblio.org/maven2'
	home = ENV['HOME'] || ENV['USERPROFILE']	
      @maven_local_repository ||= File.join(home, '.m2', 'repository')
      @maven_remote_repository = 'http://www.ibiblio.org/maven2'
	
      @group = group
      @artifact = artifact
      @version = version
      local_dir = File.join(@maven_local_repository, group.gsub('.', File::SEPARATOR), artifact, version)
      mkdir_p local_dir
        @local_location =  File.join(local_dir, "#{artifact}-#{version}.#{type}")
        @remote_location =  "#{@maven_remote_repository}/#{group.gsub('.', '/')}/#{artifact}/#{version}/#{artifact}-#{version}.#{type}"
    end
    
    def file
    "#{artifact}-#{version}.jar"
    end
    
    def install
    	return true if  File.exists?(@local_location)
     	 raise "File not found exception" unless install_remote(nil, @remote_location, @local_location)
    end
    
    def install_local(config, file, target_file)
      return false unless File.exists?(file)
      File.install(file, target_file, 0644)
      return true
    end
    
    def install_remote(config, location, target_file)
      response = read_url(location)
      return false unless response
      File.open(target_file, 'wb') { |out| out << response.body }
      return true
    end
    
    # properly download the required files, taking account of redirects
    # this code is almost straight from the Net::HTTP docs
    def read_url(uri_str, limit=10)
      raise ArgumentError, 'HTTP redirect too deep' if limit == 0
      require 'net/http'
      require 'uri'
      # setup the proxy if available
      http = Net::HTTP
      if ENV['http_proxy']
        proxy = URI.parse(ENV['http_proxy'])
        http = Net::HTTP::Proxy(proxy.host, proxy.port, proxy.user, proxy.password)
      end
      # download the file
      response = http.get_response(URI.parse(uri_str))
      case response
      when Net::HTTPSuccess then response
      when Net::HTTPRedirection then read_url(response['location'], limit - 1)
      else false
      end
    end
    
    def to_s
    "#{artifact}-#{version}"
    end
  end #class
  
  desc "Build Local Maven repository with JRuby and Jettty files"
  task :build_local_maven_for_jruby do
  	file_builders = []
  	file_builders << MavenLibraryMirror.new( 'org.jruby', 'jruby-complete', '1.0')
	file_builders << MavenLibraryMirror.new( 'org.jruby.extras', 'rails-integration', '1.1.1')
	file_builders << MavenLibraryMirror.new( 'javax.activation', 'activation', '1.1')
	file_builders << MavenLibraryMirror.new( 'commons-pool', 'commons-pool', '1.3')
	file_builders << MavenLibraryMirror.new( 'bouncycastle', 'bcprov-jdk14', '124')
	file_builders << MavenLibraryMirror.new( 'org.mortbay.jetty', 'start', '6.1.1')
	file_builders << MavenLibraryMirror.new( 'org.mortbay.jetty', 'jetty', '6.1.1')
	file_builders << MavenLibraryMirror.new( 'org.mortbay.jetty', 'jetty-util', '6.1.1')
	file_builders << MavenLibraryMirror.new( 'org.mortbay.jetty', 'servlet-api-2.5', '6.1.1')
	file_builders << MavenLibraryMirror.new( 'org.mortbay.jetty', 'jetty-plus', '6.1.1')
	file_builders << MavenLibraryMirror.new( 'org.mortbay.jetty', 'jetty-naming', '6.1.1')
	file_builders << MavenLibraryMirror.new( 'mysql', 'mysql-connector-java', '5.0.4')
	file_builders.each {|builder| p "Installing #{builder}"; builder.install}
  end
  

