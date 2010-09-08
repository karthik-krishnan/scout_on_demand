module ModelFormatter

  module ClassMethods
    alias_method :format_column_default, :format_column
    def format_column(attr, options={}, &fmt_block)
      class_inheritable_accessor :formatted_columns
      format_column_default attr, options, &fmt_block
      self.formatted_columns ||= {}
      self.formatted_columns[attr] = self.send("#{attr}_formatting_options")
    end

    def is_formatted_attribute?(formatted_attr)
      return false unless self.respond_to?(:formatted_columns) and self.formatted_columns
      formatted_attribute(formatted_attr).nil? == false
    end

    def formatted_attribute(formatted_attr)
      found = self.formatted_columns.find{|attr, options| formatted_attr.to_s == options[:formatted_attr]}
      return found[0] if found
    end
    
  end
end