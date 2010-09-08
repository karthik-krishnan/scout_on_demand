module Spec
  module Rails
    module Matchers

      class ValidatesPresenceOf < BaseValidationMatcher
      
        def initialize(attribute, options = {})
          @attribute = attribute.to_sym
          @options = options
          @invalid_value = @options[:invalid_value] || nil
          @valid_value = @options[:valid_value] || nil
        end

        def matches?(model)
          @model = model

          return false unless model.respond_to?(@attribute)
          # Collect the valid value if it wasn't already provided
          @valid_value = model.send(@attribute) if @valid_value.nil? and @invalid_value.nil?

          # Set the attribute to it's invalid value
          model.send("#{@attribute.to_s}=".to_sym, @invalid_value)

          return (!model.valid? and !model.errors.on(@attribute).blank?)
        end

        def failure_message
          message = " - #{@model.class.to_s} does not validates presence of :#{@attribute} as expected."
          message << print_out_errors(@model)
        end

        def negative_failure_message
          message = " - #{@model.class.to_s} appears to validates presence of :#{@attribute}."
          message << print_out_errors(@model)
        end

        def description
          "validate presence of #{@attribute}"
        end

      end

    end
  end
end