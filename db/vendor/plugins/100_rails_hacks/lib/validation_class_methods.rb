# 
# validation_class_methods.rb
# 
# Created on Sep 4, 2007, 3:51:20 PM
# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

module ValidationClassMethods
  module ClassMethods

    def validates_as_amount(*field_list)
      field_list = [field_list] unless field_list.is_a?(Array)
      self.validated_fields ||= {}
      field_list.each {|field_name|
        self.validated_fields[field_name] = :validate_amount
      }
    end

    def validates_as_date(*field_list)
      field_list = [field_list] unless field_list.is_a?(Array)
      self.validated_fields ||= {}
      field_list.each {|field_name|
        self.validated_fields[field_name] = :validate_date
      }
    end
    
    def validate_amount(value)
      result = true if value.nil? || value.empty?
      unless result
        plain_amount = value.gsub(/[, ]/, '')
        result = (/^([-+]?\d+)\.?$/.match(plain_amount) || /^([-+]?)(\d*)\.(\d+)$/.match(plain_amount)).nil? == false
      end
      result
    end
    
    def validate_date(value)
      result = true if value.nil? || value.empty?
      unless result
        some_date = Formatters::FormatDate.new.to(value)
        result = (some_date.nil? == false)
      end
      result      
    end
  end
  
  def self.included(klass)
    klass.extend(ClassMethods)
    
    klass.class_eval do
      
      class_inheritable_accessor :validated_fields
      
      alias_method :valid_base?, :valid?
      def valid?
        r1 = valid_base?
        r2 = true
        r3 = true
        self.validated_fields ||= {}
        validated_fields.each_pair {|k,v|
          if v.kind_of?(Symbol)
            r2 = self.class.send(v, send(k))
          else
            r2 = v.call(send(k))
          end
          unless r2 
            self.errors.add(k, " is invalid")
            r3 = false
          end
        }
        r1 && r3
      end
    end
  end
end
