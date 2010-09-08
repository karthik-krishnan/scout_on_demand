require 'erb'
require 'yaml'

@@global_ar_db_name = nil

def hack_determine_running_db_name
  return if @@global_ar_db_name.nil? == false
  mysql_return_value = ActiveRecord::Base.connection.select_value("SELECT count(TABLE_NAME) FROM information_schema.TABLES where table_schema = 'information_schema'") rescue nil
  if mysql_return_value.nil? == false
    @@global_ar_db_name = 'mysql'
    return
  end
  oracle_return_value = ActiveRecord::Base.connection.select_value("SELECT count(TABLE_NAME) FROM USER_TABLES") rescue nil
  if oracle_return_value.nil? == false
    @@global_ar_db_name = 'oracle'
    return
  end
  @@global_ar_db_name = 'db2'
end

def mysql?
  hack_determine_running_db_name
  @@global_ar_db_name == 'mysql'
end

def db2?
  hack_determine_running_db_name
  @@global_ar_db_name == 'db2'  
end

def oracle?
  hack_determine_running_db_name
  @@global_ar_db_name == 'oracle'
end
  
class Object
  self.class_eval do
    def self.is_a_model?
      ancestors.include?(ActiveRecord::Base)
    end
  end

  def class_name_table_name_map
    Dir.glob(File.join(RAILS_ROOT, 'app', 'models', '*.rb')).inject({}) do |result, fixture_file|
      class_name = File.basename(fixture_file, '.*').pluralize.classify
      class_object = class_name.constantize
      if class_object.is_a_model?
        table_name = class_object.table_name.to_s
        result[class_name] = table_name
      end
      result
    end
  end

  def generic_table_name_class_name_map
    Dir.glob(File.join(RAILS_ROOT, 'app', 'models', '*.rb')).inject({}) do |result, fixture_file|
      class_name = File.basename(fixture_file, '.*').pluralize.classify
      class_object = class_name.constantize
      if class_object.superclass == ActiveRecord::Base
        table_name = class_object.table_name
        if table_name != class_object.undecorated_table_name(class_name)
          result[table_name.to_sym] = class_name
        end
      end
      result
    end
  end
end

module ActionView
  Base.field_error_proc = Proc.new{ |html_tag, instance| "<span class=\"fieldWithErrors\">#{html_tag}</span>" }
  module Helpers
    class InstanceTag
      alias_method :error_wrapping_default, :error_wrapping
      def error_wrapping(html_tag, has_error)
        html_tag = error_wrapping_default(html_tag, has_error)
        if html_tag =~/type="radio"/
          html_tag.gsub!(/fieldWithErrors/, 'radioFieldWithErrors')
        elsif html_tag =~/type="checkbox"/
          html_tag.gsub!(/fieldWithErrors/, 'checkboxFieldWithErrors')
        end
        html_tag
      end
    end
    module FormTagHelper
      # Creates a label field
      #
      # ==== Options
      # * Creates standard HTML attributes for the tag.
      #
      # ==== Examples
      #   label_tag 'name'
      #   # => <label for="name">Name</label>
      #
      #   label_tag 'name', 'Your name'
      #   # => <label for="name">Your Name</label>
      #
      #   label_tag 'name', nil, :class => 'small_label'
      #   # => <label for="name" class="small_label">Name</label>
      def label_tag(name, text = nil, options = {})
        content_tag :label, text || name.humanize, { "for" => name }.update(options.stringify_keys)
      end
    end
  end
end

class ActiveRecord::Base
  def self.id_as_sql_condition(id_set)
    if id_set.kind_of?(Array)
      "(" + [primary_keys, id_set].transpose.map do |key, id|
        col = columns_hash[key.to_s]
        val = quote_value(id, col)
			   
        "#{key.to_s}=#{val}"
      end.join(" AND ") + ")"
    else
      "#{primary_key } = #{quote_value(id_set, columns_hash[primary_key.to_s])}"
    end            
  end
		 
  def self.undecorated_table_name(class_name)
    table_name = ActiveSupport::Inflector.demodulize(class_name)
    table_name = ActiveSupport::Inflector.pluralize(table_name)
    table_name
  end

  def to_yaml_properties
    instance_variables.sort  - ['@draft', '@audits', '@changed_attributes', '@new_record_before_save', '@versions']
  end

  TEMP_ERR_MSG = 'temp error'
  def self.fake_update_and_rollback(&block)
    begin
      transaction {
        yield
        raise TEMP_ERR_MSG
      }
    rescue => exception
      raise exception unless exception.message == TEMP_ERR_MSG
    end        
  end
end

require 'rails_generator'
require 'rails_generator/scripts/generate'

module Rails
  module Generator
    class NamedBase < Base
      def table_name
        my_table_name = ActiveSupport::Inflector.demodulize(class_name)
        my_table_name = ActiveSupport::Inflector.pluralize(my_table_name)
        my_table_name
      end
    end
  end
end

module Db2SelectAllWorkaround

  def self.included(klass)
    klass.class_eval do
      def select_all_with_db2workaround(sql, name = nil)
        begin
          select_all_without_db2workaround(sql, name)
        rescue ActiveRecord::StatementInvalid => exception 
          if exception.message =~ /String data right truncation/
            return []
          end
          raise exception
        end
      end
      alias_method_chain :select_all, :db2workaround
      
    end
  end    
end

if RUBY_PLATFORM =~ /java/
  module ActiveRecord
    module ConnectionAdapters # :nodoc:
      class JdbcAdapter 
        include Db2SelectAllWorkaround if db2?
      end
    end
  end
  
else
  
  module ActiveRecord
    module ConnectionAdapters
      class IBM_DBAdapter < AbstractAdapter
        include Db2SelectAllWorkaround if db2?
        #This quote of IBM adapter is overridden, as this expects the caller[0] to be insert_fixtures
        #or add_column_options, in some cases we must have overridden the call as in composite ibm_adapter
        #Hence we fixed by adding the caller[1] to be
        def quote(value, column = nil)
          case value
          when Numeric
            # If the column type is text or string, return the quote value
            if column && column.type.to_sym == :text || column && column.type.to_sym == :string
              unless caller[0] =~ /insert_fixture/i or caller[1] =~ /insert_fixture/i
                "'#{value}'"
              else
                "#{value}"
              end 
            else
              # value is Numeric, column.type is not a string,
              # therefore it converts the number to string without quoting it
              value.to_s
            end
          when String, ActiveSupport::Multibyte::Chars
            if column && column.type.to_sym == :binary
              # If quoting is required for the insert/update of a BLOB
              unless caller[0] =~ /add_column_options/i or caller[1] =~ /add_column_options/i
                # Invokes a convertion from string to binary
                @servertype.set_binary_value
              else
                # Quoting required for the default value of a column
                @servertype.set_binary_default(value)
              end
            elsif column && column.type.to_sym == :text
              unless caller[0] =~ /add_column_options/i or caller[1] =~ /add_column_options/i
                "'@@@IBMTEXT@@@'"
              else
                @servertype.set_text_default(quote_string(value))
              end
            elsif column && column.type.to_sym == :xml
              unless caller[0] =~ /add_column_options/i or caller[1] =~ /add_column_options/i
                "'<ibm>@@@IBMXML@@@</ibm>'"
              else
                "#{value}"
              end
            else
              unless caller[0] =~ /insert_fixture/i or caller[1] =~ /insert_fixture/i
                "'#{quote_string(value)}'"
              else
                "#{value}"
              end 
            end
          when TrueClass then quoted_true    # return '1' for true
          when FalseClass then quoted_false  # return '0' for false
          when NilClass
            if column && column.instance_of?(IBM_DBColumn) && !column.primary && !column.null
              "''"                           # allow empty inserts if not nullable or identity
            else                             # in order to support default ActiveRecord constructors
              "NULL"
            end
          else super                         # rely on superclass handling
          end
        end

      end
    end
  end

  module ActiveRecord
    module ConnectionAdapters # :nodoc:
      class OracleAdapter < AbstractAdapter
        def quote_table_name(name)
          name
        end
        def write_lobs(table_name, klass, attributes)
          if klass.composite?
            ids = klass.primary_keys.collect {|p| quote(attributes[p.to_s])}
            pk_condition = [klass.primary_keys, ids].transpose.collect{|k,v| "#{k} = #{v}"}.join(" AND ")
          else
            id = quote(attributes[klass.primary_key])
            pk_condition = "#{klass.primary_key} = #{id}"
          end
          
          klass.columns.select { |col| col.sql_type =~ /LOB$/i }.each do |col|
            value = attributes[col.name]
            value = value.to_yaml if col.text? && klass.serialized_attributes[col.name] && value
            next if value.nil?  || (value == '')
            lob = select_one("SELECT #{col.name} FROM #{table_name} WHERE #{pk_condition}",
              'Writable Large Object')[col.name]
            lob.write value
          end
        end
      end
      class OracleColumn < Column #:nodoc:
        def type_cast(value)
          return guess_date_or_time(value) if type == :datetime && OracleAdapter.emulate_dates && value.is_a?(Time)
          super
        end
      end
    end                                             
  end       
end

module Hibernate
  class Params
    def parameters
      ar_connection_params = ActiveRecord::Base.configurations[RAILS_ENV]
      adapter = ar_connection_params["adapter"]
      "Hibernate::#{adapter.classify}Params".constantize.new.parameters(ar_connection_params)
    end
  end
  
  class MysqlParams < Params
    def parameters(ar_params)
      hibernate_params = {}
      hibernate_params["hibernate.dialect"] = "org.hibernate.dialect.MySQLInnoDBDialect"
      hibernate_params["hibernate.connection.driver_class"] = "com.mysql.jdbc.Driver"
      host = ar_params["host"] || "localhost"
      port = ar_params[:port] || 3306
      hibernate_params["hibernate.connection.url"] = "jdbc:mysql://#{host}:#{port}/#{ar_params["database"]}"
      hibernate_params["hibernate.connection.username"] = ar_params["username"]
      hibernate_params["hibernate.connection.password"] = ar_params["password"] || ''
      hibernate_params
    end
  end
  
  class JdbcParams < Params
    def parameters(ar_params)
      hibernate_params = {}
      hibernate_params["hibernate.connection.datasource"] = ar_params["jndi"]
      hibernate_params["hibernate.dialect"] = (
        case ar_params["driver"]
        when "mysql"
          "org.hibernate.dialect.MySQLInnoDBDialect"
        when "oracle"
          "org.hibernate.dialect.Oracle9Dialect"
        end
      )
      hibernate_params
    end
  end
  
  class OciParams < Params
    def parameters(ar_params)
      {}
    end
  end

  class IbmDbParams < Params
    def parameters(ar_params)
      {}
    end
  end
end    
module ActionController::Layout

  ## Karthik:
  # pick_layout method in Rails 2.2.2 has couple of issues
  # 1. If Layout is passed as NIL, he still was going and rendering the layout
  # 2. When checking whether to exempt from layout, when layout is passed as True, default_template_name
  # should be passed only if the options[:template] is not passed and also default_template_name should be supplied
  # with the options[:action] as parameter(we copied that logic from candidate_for_layout? method
  #
  def pick_layout(options)
    if options.has_key?(:layout)
      case layout = options.delete(:layout)
      when NilClass, FalseClass
        nil
      when TrueClass
        active_layout if action_has_layout? && !@template.__send__(:_exempt_from_layout?, options[:template] || default_template_name(options[:action]))
      else
        active_layout(layout)
      end
    else
      active_layout if action_has_layout? && candidate_for_layout?(options)
    end
  end

end

module ActionView
  module Helpers
    module ActiveRecordHelper
      def error_messages_for(*params)
        options = params.extract_options!.symbolize_keys

        if object = options.delete(:object)
          objects = [object].flatten
        else
          objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
        end

        count  = objects.inject(0) {|sum, object| sum + object.errors.count }
        unless count.zero?
          html = {}
          [:id, :class].each do |key|
            if options.include?(key)
              value = options[key]
              html[key] = value unless value.blank?
            else
              html[key] = 'errorExplanation'
            end
          end
          options[:object_name] ||= params.first

          I18n.with_options :locale => options[:locale], :scope => [:activerecord, :errors, :template] do |locale|
            header_message = if options.include?(:header_message)
              options[:header_message]
            else
              object_name = options[:object_name].to_s.gsub('_', ' ')
              object_name = I18n.t(object_name, :default => object_name, :scope => [:activerecord, :models], :count => 1)
              locale.t :header, :count => count, :model => object_name
            end
            #Shanmugam Dec '08
            # count is passed in translation method, otherwise error messages shows both singular (:one) and plural (:other)
            message = options.include?(:message) ? options[:message] : locale.t(:body, :count => count)
            error_messages = objects.sum {|object| object.errors.full_messages.map {|msg| content_tag(:li, msg) } }.join

            contents = ''
            contents << content_tag(options[:header_tag] || :h2, header_message) unless header_message.blank?
            contents << content_tag(:p, message) unless message.blank?
            contents << content_tag(:ul, error_messages)

            content_tag(:div, contents, html)
          end
        else
          ''
        end
      end
    end
  end
end

class ActiveRecord::ConnectionAdapters::Column
  def self.fallback_string_to_date(string)
    Date.strptime(string, I18n.translate(:'date.formats')[:default]) unless string.blank?
  end
end

unless RUBY_PLATFORM =~ /java/
  if mysql?
    class ActiveRecord::ConnectionAdapters::MysqlColumn
      alias_method :missing_default_forged_as_empty_string_original?, :missing_default_forged_as_empty_string?
      def missing_default_forged_as_empty_string?(default)
        if type == :date
          !null && default == '0000-00-00'
        else
          missing_default_forged_as_empty_string_original?(default)
        end
      end
    end
  end
end


class ActiveRecord::Base
  class << self
    def find_last(options)
      order = options[:order]

      if order
        order = reverse_sql_order(order)
      elsif !scoped?(:find, :order)
        order = "#{table_name}.#{primary_key} DESC"
      end

      if scoped?(:find, :order)
        scope = scope(:find)
        original_scoped_order = scope[:order]
        scope[:order] = reverse_sql_order(original_scoped_order)
      end

      begin
        find_initial(options.merge({ :order => order }))
      ensure
        scope[:order] = original_scoped_order if original_scoped_order
      end
    end
  end

end

if RUBY_PLATFORM =~ /java/ and RAILS_ENV == 'production'
  class ActiveRecord::ConnectionAdapters::ConnectionPool
    def checkout
      # Checkout an available connection
      @connection_mutex.synchronize do
        checkout_new_connection
      end
    end

    def checkin(conn)
      @connection_mutex.synchronize do
        conn.run_callbacks :checkin
        @checked_out.delete conn
        @queue.signal
        @connections.delete(conn)
        conn.disconnect!
      end
    end
  end
end

#Portal Integration(infact code is specific to Liferay as we are looking for a specific cookie name)
#Had to override the entire method since the code is not easily pluggable.
#Ajax URL should be converted to Portlet Resource Urls when running inside a Portal

module ActionView
  module Helpers
    module PrototypeHelper
      def remote_function(options)
        javascript_options = options_for_ajax(options)

        update = ''
        if options[:update] && options[:update].is_a?(Hash)
          update  = []
          update << "success:'#{options[:update][:success]}'" if options[:update][:success]
          update << "failure:'#{options[:update][:failure]}'" if options[:update][:failure]
          update  = '{' + update.join(',') + '}'
        elsif options[:update]
          update << "'#{options[:update]}'"
        end

        function = update.empty? ?
          "new Ajax.Request(" :
          "new Ajax.Updater(#{update}, "

        url_options = options[:url]
        url_options = url_options.merge(:escape => false) if url_options.is_a?(Hash)
        url = url_for(url_options)
        new_url = url_options.is_a?(Hash) ? url : url_options
        if cookies[:Liferay_resourceUrl]
          url = prepare_portal_resource_url(new_url)
        end        
		function << "'#{escape_javascript(url)}'"
        function << ", #{javascript_options})"

        function = "#{options[:before]}; #{function}" if options[:before]
        function = "#{function}; #{options[:after]}"  if options[:after]
        function = "if (#{options[:condition]}) { #{function}; }" if options[:condition]
        function = "if (confirm('#{escape_javascript(options[:confirm])}')) { #{function}; }" if options[:confirm]

        return function
      end
    end
  end
end

def prepare_portal_resource_url(url)
  if cookies[:portal_resource_url]
    portal_resource_url = cookies[:portal_resource_url]
    portlet_parameter_prefix = portal_resource_url.scan(/p_p_id=(\w*)/)[0][0]
    portal_resource_url.gsub!(/&\w*_railsRoute=.*$/, "")
    portlet_url =  portal_resource_url + "&_#{portlet_parameter_prefix}_railsRoute="
    require 'cgi'
    url = portlet_url + CGI.escape(url)
  end
  url
end

def prepare_portal_render_url(url)
  if cookies[:portal_render_url]
    portal_render_url = cookies[:portal_render_url]
    portlet_parameter_prefix = portal_render_url.scan(/p_p_id=(\w*)/)[0][0]
    portal_render_url.gsub!(/&\w*_railsRoute=.*$/, "")
    portlet_url =  portal_render_url + "&_#{portlet_parameter_prefix}_railsRoute="
    require 'cgi'
    url = portlet_url + CGI.escape(url)
  end
  url
end

