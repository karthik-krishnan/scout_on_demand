# From Brandon Keepers post on March 2nd\
module Spec
  module Rails
    module Matchers
      class AssociationMatcher  #:nodoc:

        def initialize(type, name, options = {})
          @type = type
          @name = name
          @options = options
          @class_name = if @options[:class_name]
            @options[:class_name]
          elsif @options[:source] 
            @options[:source].to_s.classify 
          elsif @type == :has_one || @type == :belongs_to
            @name.to_s.camelize
          else
            @name.to_s.singularize.camelize
          end
        end

        def matches?(model)
          @model = model
          @association = model.class.reflect_on_association(@name)
          return false if @association.nil?
          
          # Assume we don't wish to consider the options if none are provided
          @options = @association.options if @options.blank?
          @options[:extend] ||= [] if @type == :has_many || @type == :has_and_belongs_to_many
          @association.macro == @type && @association.class_name == @class_name && @association.options == @options
        end

        def failure_message
          "expected #{model.inspect} to have a #{type} association called :#{name}\n\n but found the following:\n\n #{association.inspect}"
        end

        def description
          "have a #{type} association called :#{name}"
        end

        private
          attr_reader :type, :name, :model, :association
      end
    end
  end
end
