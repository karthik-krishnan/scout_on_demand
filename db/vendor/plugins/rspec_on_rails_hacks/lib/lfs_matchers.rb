# AssociationSpecMatcher.rb
# June 18, 2007
#
require 'rexml/document'
require 'rexml/element'

module LfsMatchers
    class MoneyAttrMatcher
  
        def initialize(attr_name, options = nil)
            @attr_name = attr_name
            @options = options
        end

        def description
            "have a Money attribute named #{@attr_name}"
        end

        def matches?(target)
            @target = target
            money_attrs_for_class = ActiveRecord::Base.money_attributes_for_class(@target)
            @money_attributes = money_attrs_for_class.inject({}) {|result , a| result[a[:attr_name]] = a[:currency_column]; result }
            @money_attributes.keys.any? {|a|
                a == @attr_name && (@options.nil? || @money_attributes[a] == (@options[:currency_column] || @money_attributes[a]))
            }
        end

        def failure_message
            msg = "expected #{@attr_name}, "
            if @money_attributes.keys.size > 0
                if @money_attributes[@attr_name].nil?
                    msg += "but found only " + @money_attributes.keys.join(', ') 
                else
                    msg = "expected #{@attr_name} with currency column #{@options[:currency_column]} but found currency column as #{@money_attributes[@attr_name]}"
                end
            else
                msg += "but no money attributes defined."      
            end
            msg
        end
    
        def negative_failure_message
            "expected #{@attr_name} not to have been defined as money attribute."
        end
    
    end
  
    def have_money_attribute(attr_name, options = {})
        MoneyAttrMatcher.new(attr_name, options)
    end

  
    class FormatColumnMatcher
        def initialize(attr, *args)
            @attr = attr
            @options = args.last.is_a?(Hash) ? args.last : {}
      
            @expected_as = @options.delete(:as)
            @expected_formatter = @options.delete(:formatter)
      
            if (@expected_formatter.nil? && @expected_as.nil?) ||
                  (@expected_formatter.nil? == false && @expected_as.nil? == false)
                raise("validate_format_of requires either :formatter option or :as option.")
            end
      
        end    
    
        def description
            if (@expected_as)
                desc = "format #{@attr} as #{@expected_as}"
            elsif(@expected_formatter)
                desc = "format #{@attr} using #{@expected_formatter}"
            end
            desc += " with prefix '#{@options[:prefix]}'" if @options[:prefix]
            desc
        end
    
        def matches?(target)
            @result = "expected #{@attr} to be formatted"
            @result += " as #{@expected_as}" if @expected_as
            @result += " using #{@expected_formatter}" if @expected_formatter
       
       
            unless target.is_formatted?(@attr)
                @result += " but no format has been specified for #{@attr}"
                return false
            end
       
            @fmt_options = target.send("#{@attr}_formatting_options")

            unless @expected_as.nil? || @fmt_options[:as] == @expected_as
                @result += " but found it to be formatted as #{@fmt_options[:as]}"
                return false
            end
       
            unless @expected_formatter.nil? || @fmt_options[:formatter].class.name == @expected_formatter
                @result += " but found it to be formatted using #{@fmt_options[:formatter].class.name}"
                return false
            end
       
            @options.each_pair {|key, value|
                unless value == @fmt_options[key]
                    @result += " expected #{key} to be '#{value}'"
                    @result += " but found #{key} to be '#{@fmt_options[key]}'"
                    return false
                end
            }
            true
        end
    
        def failure_message
            @result
        end
    
        def negative_failure_message
      
        end
  
    end
  
    def format_column(attr_name, options)
        FormatColumnMatcher.new(attr_name, options)
    end
  
    class SortColumnMatcher

        def initialize(*args) 
            @sort_name = args.first.is_a?(Hash) ? 'list' : args.first
            @options = args.last.is_a?(Hash) ? args.last : {}
            raise "Sort options cannot be blank" if @options.blank?
            @options[:sort_name] = @sort_name
        end
    
        def description
            msg = "allow sort on"
            msg += " sort name => #{@sort_name}"
            msg += ", alias => #{@options[:alias]}" if @options[:alias]
            msg += ", model => #{@options[:model]}" if @options[:model]
            msg += ", field => #{@options[:field]}" if @options[:field]
            msg
        end
    
        def matches?(target)
            @target = target
            @target.sortable_column_header_data.any? {|v|
                v == @options
            }
        end
    
        def failure_message
            "expected #{self.description} but not found"
      
        end
    
        def negative_failure_message
            "not expected #{description} but found"
        end
    
    end
  
    def allow_sort_on(*args)
        SortColumnMatcher.new(*args)
    end
  
    def by_default_sort_on(*args)
    
    end
  
    class PrimaryKeyMatcher
        def initialize(expected_keys)
            @expected_keys = expected_keys
        end
    
        def description
            "have primary key(s) as #{@expected_keys.inspect}"
        end
    
        def matches?(target)
            @target = target
            found_keys = @target.primary_key.is_a?(String) ? [@target.primary_key.to_sym] : @target.primary_key.collect
            found_keys == @expected_keys
        end
    
        def failure_message
            "expected primary key(s) to be #{@expected_keys.join(',')}, but found #{@target.primary_key}"
        end
    
        def negative_failure_message
            "expected primary key(s) not to be #{@expected_keys}"
        end
    end
  
    def have_primary_keys(*args)
        PrimaryKeyMatcher.new(args)
    end
  
    def have_primary_key(key)
        PrimaryKeyMatcher.new([key])
    end

    class ActsAsStateMachineMatcher
        def initialize(initial_state, state_column)
            @initial_state = initial_state
            @state_column = state_column
        end
    
        def description
            "have state machine with #{@initial_state} as initial state and #{@state_column} as state column"
        end
    
        def matches?(target)
            @target = target
            @target_initial_state = @target.read_inheritable_attribute(:initial_state)
            @target_state_column = @target.read_inheritable_attribute(:state_column)
            @target.read_inheritable_attribute(:transition_table) && 
              @target_initial_state == @initial_state && 
              @target_state_column == @state_column
        end
    
        def failure_message
            return "#{@target.name} does not act as state machine" unless @target.read_inheritable_attribute(:transition_table)
            msg = ''
            msg += "expected initial state to be #{@initial_state}, but found #{@target_initial_state}" unless @target_initial_state == @initial_state
            msg += "expected state column to be #{@state_column}, but found #{@target_state_column}" unless @target_state_column == @state_column
        end
    
        def negative_failure_message
            "#{@target.name} should not act as state machine"
        end
    
    end
  
    def act_as_state_machine(options = {})
        ActsAsStateMachineMatcher.new(options[:initial], options[:column] || 'state')
    end
  
    module ActsAsStateMachine
        class TransitionMatcher
            def initialize(event, to, from, guard)
                @event = event
                @to = to
                @from = [from].flatten
                @guard = guard
            end
    
            def description
                "have state transition for event:[#{@event}] from state:#{@from.inspect} to state:[#{@to}]" + (@guard ? " with guard [#{@guard}]" : '')
            end
    
            def matches?(target)
                @target = target
                @tt = @target.read_inheritable_attribute(:transition_table)
                return false unless @tt
                @event_transitions = @tt[@event]
                return false unless @event_transitions
                @event_transitions.select {|t|
                    @from.include?(t.from) && t.to == @to && (t.opts[:guard] == (@guard || t.opts[:guard]))
                }.size == @from.size
            end
    
            def failure_message
                return "#{@target.name} does not act as state machine" unless @tt
                return "state machine does not have the event:[#{@event}]" unless @event_transitions
                "expected state transition for event:[#{@event}] from state:#{@from.inspect} to state:[#{@to}]" + 
                  (@guard ? " with guard [#{@guard}]" : '') +
                  ", but found the following " + @event_transitions.inspect
            end
    
            def negative_failure_message
                "#{@target.name} should not have state transition for event:[#{@event}] from state:#{@from.inspect} to state:[#{@to}]" +
                  (@guard ? " with guard [#{@guard}]" : '')
            end
      
        end

        class StatesMatcher
            def initialize(states)
                @states = states
            end
    
            def description
                "have states:#{@states.inspect}"
            end
    
            def matches?(target)
                @target = target
                @tt = @target.read_inheritable_attribute(:transition_table)
                state_hash = @target.read_inheritable_attribute(:states)
                @existing_states = state_hash.keys
                return false unless @existing_states
                @existing_states.contains?(@states)
            end
    
            def failure_message
                return "#{@target.name} does not act as state machine" unless @tt
                return "state machine does not have any states defined" unless @existing_states
                "expected states:#{@states.inspect} but found:#{@existing_states.inspect}"
            end
    
            def negative_failure_message
                "#{@target.name} should not have states:#{@states}"
            end
        end
    
        class StateMatcher
            def initialize(state, enter, after, exit)
                @state = state
                @enter = enter
                @after = after
                @exit = exit
            end
    
            def description
                "have state:#{@state}" + (@enter ? ", :enter => #{@enter}" : '') + 
                  (@after ? ", :after => #{@after}" : '') + 
                  (@exit ? ", :exit => #{@exit}" : '')
            end
    
            def matches?(target)
                @target = target
                @tt = @target.read_inheritable_attribute(:transition_table)
                state_hash = @target.read_inheritable_attribute(:states)
                @existing_state = state_hash[@state]
                @existing_state_opts = @existing_state.instance_variable_get('@opts')
                @existing_state && @existing_state_opts[:enter] == @enter && @existing_state_opts[:after] == @after && @existing_state_opts[:exit] == @exit
            end
    
            def failure_message
                return "#{@target.name} does not act as state machine" unless @tt
                return "state machine does not have state:[#{@existing_state}] defined" unless @existing_state
                "expected state:#{@state}" + (@enter ? ", :enter => #{@enter}" : '') + 
                  (@after ? ", :after => #{@after}" : '') + (@exit ? ", :exit => #{@exit}" : '') +
                  ", but found state:#{@state}" + (@existing_state_opts[:enter] ? ", :enter => #{@existing_state_opts[:enter]}" : '') + 
                  (@existing_state_opts[:after] ? ", :after => #{@existing_state_opts[:after]}" : '') + (@existing_state_opts[:exit] ? ", :exit => #{@existing_state_opts[:exit]}" : '')
            end
    
            def negative_failure_message
                "#{@target.name} should not have state:#{@state}"
            end
        end
    end
  
    def have_state_transition(options = {})
        ActsAsStateMachine::TransitionMatcher.new(options[:event], options[:to], options[:from], options[:guard])
    end
  
    def have_states(states)
        ActsAsStateMachine::StatesMatcher.new(states)
    end
  
    def have_state(state, options = {})
        ActsAsStateMachine::StateMatcher.new(state, options[:enter], options[:after], options[:exit])
    end

    module Validatable

        class IncludeValidationsMatcher
            def initialize(model_name, options)
                @model_name = model_name
                @map = options[:map] || {}
                @if = options[:if] || :always_validate
            end

            def description
                "include validations for #{@model_name}" + (@map ? ", with #{@map.inspect}" : '') + (@if ? ", if #{@if.inspect}" : '')
            end

            def matches?(target)
                @target = target
                @children_to_validate = @target.send(:children_to_validate) rescue nil
                return false unless @children_to_validate
                @child = @children_to_validate.find{|a| a.attribute == @model_name}
                return false unless @child
                return false if @child.map != @map
                return false if @child.should_validate_proc != @if
                true
            end

            def failure_message
                return "#{@target.name} does not include validations for #{@model_name}" unless @child
                msg = ''
                msg += "\n expected map: #{@map.inspect} but found: #{@child.map.inspect}" unless @child.map == @map
                msg += "\n expected if: #{@if} but found: #{@child.should_validate_proc}" unless @child.should_validate_proc == @if
                msg
            end

            def negative_failure_message
                "#{@target.name} should not include validations for #{@model_name}"
            end
        end
    end
  
    def include_validations_for(model_name, options = {})
        Validatable::IncludeValidationsMatcher.new(model_name, options)
    end
  
    class AttrLockedMatcher
        def initialize(column_name)
            @column_name = column_name
        end
    
        def description
            "have the column :#{@column_name} locked during edit"
        end
    
        def matches?(target)
            @target = target
            @target.class.attr_readonly.include?(@column_name.to_s)
        end
    
        def failure_message
            "attr_locked is not set for the column :#{@column_name} in #{@target.class} class"
        end
    
        def negative_failure_message
            "attr_locked should not be set for the column :#{@column_name} in #{@target.class} class"
        end
    
        private
    
        attr_accessor :column_name, :target
    end
  
    def have_attr_locked(column_name)
        AttrLockedMatcher.new(column_name)
    end
  
    class ActsAsInstrumentableMatcher
        def initialize(instrument_name)
            @instrument_name = instrument_name
        end
    
        def description
            "have act as instrumentable with #{@instrument_name} as instrument"
        end
    
        def matches?(target)
            @target = target
            @target.included_modules.include?(ActsAsInstrumentable)
        end
    
        def failure_message
            return "#{@target.name} does not act as instrumentable"
        end
    
        def negative_failure_message
            "#{@target.name} should not act as instrumentable"
        end
    
    end
  
    def act_as_instrumentable(instrument_name)
        ActsAsInstrumentableMatcher.new(instrument_name)
    end
  
    class ValidateFormatOfMatcher
        def initialize(field_name, format)
            @field_name = field_name
            @expected_format = format.to_s
        end
    
        def description
            "have validate format of #{@field_name}, as #{@expected_format}"
        end
    
        def matches?(target)
            @target = target
            return false if @target.validated_fields[@field_name].nil?
            @validates_as = @target.validated_fields[@field_name].to_s.scan(/validate_(.*)/).flatten[0] if @target.validated_fields[@field_name].to_s =~ /validate_/
            @validates_as == @expected_format
        end
    
        def failure_message
            if @target.validated_fields[@field_name] == nil
                return "#{@target.name} does not validate format of #{@field_name}"
            else
                return "expected #{@field_name} to be validated as #{@expected_format}, 
            but found to be validating as #{@validates_as}"
            end  
        end
    
        def negative_failure_message
            "#{@target.name} should not validate format of #{@field_name}"
        end
    
    end

    def validate_format_of(field_name, format)
        ValidateFormatOfMatcher.new(field_name, format)
    end  

    class ValidateNumericalityOf

        def initialize(attribute, options = {})
            @attribute = attribute.to_sym
            @options = options
            @invalid_value = @options[:invalid_value] || 'a'
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
            return message = " - #{@model.class.to_s} does not numericality of :#{@attribute} as expected."
        end

        def negative_failure_message
            return message = " - #{@model.class.to_s} appears to validates numericality of :#{@attribute}."
        end

        def description
            "validate numericality of #{@attribute}"
        end

    end

    def validate_numericality_of(field_name, options = {})
        ValidateNumericalityOf.new(field_name, options)
    end




    # check if the xpath exists one or more times
    class HaveXpath
        def initialize(xpath)
            @xpath = xpath
        end

        def matches?(response)
            @response = response
            doc = response.is_a?(REXML::Document) ? response : REXML::Document.new(@response)
            match = REXML::XPath.match(doc, @xpath)
            not match.empty?
        end

        def failure_message
            "Did not find expected xpath #{@xpath}"
        end

        def negative_failure_message
            "Did find unexpected xpath #{@xpath}"
        end

        def description
            "match the xpath expression #{@xpath}"
        end
    end

    def have_xpath(xpath)
        HaveXpath.new(xpath)
    end

    # check if the xpath has the specified value
    # value is a string and there must be a single result to match its
    # equality against
    class MatchXpath
        def initialize(xpath, val)
            @xpath = xpath
            @val= val
        end

        def matches?(response)
            @response = response
            doc = response.is_a?(REXML::Document) ? response : REXML::Document.new(@response)
            ok= true
            REXML::XPath.each(doc, @xpath) do |e|
                @actual_val= case e
                when REXML::Attribute
                    e.to_s
                when REXML::Element
                    e.text
                else
                    e.to_s
                end
                return false unless @val == @actual_val
            end
            return ok
        end

        def failure_message
            "The xpath #{@xpath} did not have the value '#{@val}'\nIt was '#{@actual_val}'"
        end

        def description
            "match the xpath expression #{@xpath} with #{@val}"
        end
    end

    def match_xpath(xpath, val)
        MatchXpath.new(xpath, val)
    end

    # checks if the given xpath occurs num times
    class HaveNodes  #:nodoc:
        def initialize(xpath, num)
            @xpath= xpath
            @num = num
        end

        def matches?(response)
            @response = response
            doc = response.is_a?(REXML::Document) ? response : REXML::Document.new(@response)
            match = REXML::XPath.match(doc, @xpath)
            @num_found= match.size
            @num_found == @num
        end

        def failure_message
            "Did not find expected number of nodes #{@num} in xpath #{@xpath}\nFound #{@num_found}"
        end

        def negative_failure_message
            "Found xpath #{@xpath}"
        end
        
        def description
            "match the number of nodes #{@num}"
        end
    end

    def have_nodes(xpath, num)
        HaveNodes.new(xpath, num)
    end

end



  
