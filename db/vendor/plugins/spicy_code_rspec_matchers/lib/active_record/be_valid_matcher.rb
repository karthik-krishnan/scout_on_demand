require File.join(File.dirname(__FILE__), 'base_validation_matcher')
# From http://opensoul.org/2007/4/18/rspec-model-should-be_valid
module Spec
  module Rails
    module Matchers

      class BeValid < BaseValidationMatcher

        def matches?(model)
          @model = model
          @model.valid?
        end

        def failure_message
          "- #{@model.class} was invalid."
          print_out_errors(@model)
        end
        
        def negative_failure_message
          "- #{@model.class} was valid."
          print_out_errors(@model)
        end

        def description
          "be valid"
        end

      end
      
    end
  end
end