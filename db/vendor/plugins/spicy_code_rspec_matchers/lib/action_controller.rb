require 'spec'

require File.join(File.dirname(__FILE__), 'action_controller/route_matcher')

module Spec
  module Rails
    module Matchers
      
      def map_route(desired_url = '', route_hash = {})
        Spec::Rails::Matchers::RouteMatcher.new(desired_url, route_hash)
      end
      
    end
  end
end