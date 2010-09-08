module Validatable
  class ChildValidation #:nodoc:
    attr_accessor :attribute, :map, :should_validate_proc
    
    def initialize(attribute, map, should_validate_proc)
      @attribute = attribute
      @map = map
      @should_validate_proc = should_validate_proc
    end
    
    def should_validate?(instance)
      if should_validate_proc.instance_of?(Symbol)
        return true if should_validate_proc == :always_validate
        instance.send(should_validate_proc)
      else
        instance.instance_eval &should_validate_proc
      end
    end
  end
end