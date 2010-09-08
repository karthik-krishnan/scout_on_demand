module Validatable
  module Macros
    # call-seq: validates_format_of(*args)
    # 
    # Validates whether the value of the specified attribute is of the 
    # correct form by matching it against the regular expression provided.
    # 
    #   class Person
    #     include Validatable    
    #     validates_format_of :first_name, :with => /[ A-Za-z]/
    #   end
    # 
    # A regular expression must be provided or else an exception will be raised.
    # 
    # Configuration options:
    # 
    #     * message - The message to add to the errors collection when the validation fails
    #     * times - The number of times the validation applies
    #     * level - The level at which the validation should occur
    #     * if - A block that when executed must return true of the validation will not occur
    #     * with - The regular expression used to validate the format
    #     * group - The group that this validation belongs to.  A validation can belong to multiple groups
    def validates_format_of(*args)
      add_validations(args, ValidatesFormatOf)
    end
    
    # call-seq: validates_length_of(*args)
    # 
    # Validates that the specified attribute matches the length restrictions supplied.
    # 
    #   class Person
    #     include Validatable
    #     validates_length_of :first_name, :maximum=>30
    #     validates_length_of :last_name, :minimum=>30
    #   end
    # 
    # Configuration options:
    # 
    #     * message - The message to add to the errors collection when the validation fails
    #     * times - The number of times the validation applies
    #     * level - The level at which the validation should occur
    #     * if - A block that when executed must return true of the validation will not occur
    #     * minimum - The minimum size of the attribute
    #     * maximum - The maximum size of the attribute
    #     * is - The size the attribute must be
    #     * within - A range that the size of the attribute must fall within
    #     * group - The group that this validation belongs to.  A validation can belong to multiple groups
    def validates_length_of(*args)
      add_validations(args, ValidatesLengthOf)
    end

    # call-seq: validates_numericality_of(*args)
    # 
    # Validates that the specified attribute is numeric.
    # 
    #   class Person
    #     include Validatable
    #     validates_numericality_of :age
    #   end
    # 
    # Configuration options:
    # 
    #     * message - The message to add to the errors collection when the validation fails
    #     * times - The number of times the validation applies
    #     * level - The level at which the validation should occur
    #     * if - A block that when executed must return true of the validation will not occur
    #     * group - The group that this validation belongs to.  A validation can belong to multiple groups
    #     * only_integer - Whether the attribute must be an integer (default is false)
    def validates_numericality_of(*args)
      add_validations(args, ValidatesNumericalityOf)
    end

    # call-seq: validates_acceptance_of(*args)
    #
    # Encapsulates the pattern of wanting to validate the acceptance of a terms of service check box (or similar agreement). Example:
    # 
    #   class Person
    #     include Validatable
    #     validates_acceptance_of :terms_of_service
    #     validates_acceptance_of :eula, :message => "must be abided"
    #   end
    #
    # Configuration options:
    # 
    #     * message - The message to add to the errors collection when the validation fails
    #     * times - The number of times the validation applies
    #     * level - The level at which the validation should occur
    #     * if - A block that when executed must return true of the validation will not occur
    #     * group - The group that this validation belongs to.  A validation can belong to multiple groups
    def validates_acceptance_of(*args)
      add_validations(args, ValidatesAcceptanceOf)
    end

    # call-seq: validates_confirmation_of(*args)
    #
    # Encapsulates the pattern of wanting to validate a password or email address field with a confirmation. Example:
    # 
    #   Class:
    #     class PersonPresenter
    #       include Validatable
    #       validates_confirmation_of :user_name, :password
    #       validates_confirmation_of :email_address, :message => "should match confirmation"
    #     end
    # 
    #   View:
    #     <%= password_field "person", "password" %>
    #     <%= password_field "person", "password_confirmation" %>
    #
    # Configuration options:
    # 
    #     * case_sensitive - Whether or not to apply case-sensitivity on the comparison.  Defaults to true.
    #     * message - The message to add to the errors collection when the validation fails
    #     * times - The number of times the validation applies
    #     * level - The level at which the validation should occur
    #     * if - A block that when executed must return true of the validation will not occur
    #     * group - The group that this validation belongs to.  A validation can belong to multiple groups
    def validates_confirmation_of(*args)
      add_validations(args, ValidatesConfirmationOf)
    end
  
    # call-seq: validates_presence_of(*args)
    # 
    # Validates that the specified attributes are not nil or an empty string
    # 
    #   class Person
    #     include Validatable
    #     validates_presence_of :first_name
    #   end
    #
    # The first_name attribute must be in the object and it cannot be nil or empty.
    #
    # Configuration options:
    # 
    #     * message - The message to add to the errors collection when the validation fails
    #     * times - The number of times the validation applies
    #     * level - The level at which the validation should occur
    #     * if - A block that when executed must return true of the validation will not occur
    #     * group - The group that this validation belongs to.  A validation can belong to multiple groups
    def validates_presence_of(*args)
      add_validations(args, ValidatesPresenceOf)
    end
    
    # call-seq: validates_true_for(*args)
    # 
    # Validates that the logic evaluates to true
    # 
    #   class Person
    #     include Validatable
    #     validates_true_for :first_name, :logic => lambda { first_name == 'Jamie' }
    #   end
    #
    # The logic option is required.
    #
    # Configuration options:
    # 
    #     * message - The message to add to the errors collection when the validation fails
    #     * times - The number of times the validation applies
    #     * level - The level at which the validation should occur
    #     * if - A block that when executed must return true of the validation will not occur
    #     * group - The group that this validation belongs to.  A validation can belong to multiple groups
    #     * logic - A block that executes to perform the validation
    def validates_true_for(*args)
      add_validations(args, ValidatesTrueFor)
    end
    
    # call-seq: include_validations_for(attribute_to_validate, options = {})
    # 
    # Validates the specified attributes.
    #   class Person
    #     include Validatable
    #     validates_presence_of :name
    #     attr_accessor :name
    #   end
    # 
    #   class PersonPresenter
    #     include Validatable
    #     include_validations_for :person, :map => { :name => :namen }, :if => lambda { not person.nil? }
    #     attr_accessor :person
    #     
    #     def initialize(person)
    #       @person = person
    #     end
    #   end
    #   
    #   presenter = PersonPresenter.new(Person.new)
    #   presenter.valid? #=> false
    #   presenter.errors.on(:namen) #=> "can't be blank"
    #
    # The person attribute will be validated.  
    # If person is invalid the errors will be added to the PersonPresenter errors collection.
    #
    # Configuration options:
    # 
    #     * map - A hash that maps attributes of the child to attributes of the parent.
    #     * if - A block that when executed must return true of the validation will not occur.
    def include_validations_for(attribute_to_validate, options = {})
      children_to_validate << ChildValidation.new(attribute_to_validate, options[:map] || {}, options[:if] || :always_validate )
    end
  end
end