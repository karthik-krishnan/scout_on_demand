# RspecOnRailsHacks

#class Spec::Rails::Matchers::RedirectTo
#  def path_hash(url)
#    path = url.sub(%r{^\w+://#{@request.host}}, "").split("?", 2)[0]
#    path = path.split("/")[1..-1] if ::Rails::VERSION::MINOR < 2
#    ActionController::Routing::Routes.recognize_path path, {:method => @request.method}
#  end
#end

module Spec
  module Example
    class Configuration
      # All of this is ActiveRecord related and makes no sense if it's not used by the app
      if defined?(ActiveRecord::Base)
        def fixture_classes=(table_name_class_map)
          EXAMPLE_GROUP_CLASSES.each do |example_group|
            example_group.set_fixture_class table_name_class_map
          end
          #::Spec::Rails::Example::ModelExampleGroup.set_fixture_class(table_name_class_map)
        end
        
        def global_fixtures=(fixtures)
          ::Spec::Rails::Example::ModelExampleGroup.fixtures(*fixtures)
        end
        
      end
    end
  end
end

module Spec::Matchers::Watir
  class ErrorElementMatcher
     def initialize(element_id)
	@element_id = element_id
     end

     def matches?(container)
      @container = container
      begin
	element = @container.element_by_xpath("//span[@class='fieldWithErrors']/*[@id='#{@element_id}']")
        if element.respond_to?(:assert_exists)
          # IE
          element.assert_exists
          true
        else
          # Safari
          element.exists?
        end
      rescue ::Watir::Exception::UnknownObjectException => e
        false
      end
    end
    
    def failure_message
      "Expected page to have error on #{@element_id} but either element is not found or element doesn't contain error"
    end

    def negative_failure_message
      "Expected page to not have error on #{@element_id} but either element is not found or element contain error"
    end
  end

  def have_error_on(element_name)
	ErrorElementMatcher.new(element_name)
  end
end
