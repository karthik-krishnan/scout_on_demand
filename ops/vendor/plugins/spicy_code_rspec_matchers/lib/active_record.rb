require File.join(File.dirname(__FILE__), 'active_record/association_matcher')
require File.join(File.dirname(__FILE__), 'active_record/be_valid_matcher')
require File.join(File.dirname(__FILE__), 'active_record/base_validation_matcher')
require File.join(File.dirname(__FILE__), 'active_record/validates_presence_of')
require File.join(File.dirname(__FILE__), 'active_record/validates_confirmation_of')
require File.join(File.dirname(__FILE__), 'active_record/validates_uniqueness_of')
require File.join(File.dirname(__FILE__), 'active_record/validates_length_of')

require 'spec'

module Spec
  module Rails
    module Matchers
      
      def validate_presence_of(attr, options = { })
        Spec::Rails::Matchers::ValidatesPresenceOf.new(attr, options)
      end
      alias_method :require_presence_of, :validate_presence_of

      def validate_confirmation_of(attr, options = { })
        Spec::Rails::Matchers::ValidatesConfirmationOf.new(attr, options)
      end
      alias_method :require_confirmation_of, :validate_confirmation_of

      def validate_uniqueness_of(attr, options = { })
        Spec::Rails::Matchers::ValidatesUniquenessOf.new(attr, options)
      end

      def validate_acceptance_of(attr, options = { })

      end

      def validate_associated(associated_model, options = { })

      end

      def validate_exclusion_of(attr, options = { })

      end

      def validate_format_of(attr, options = { })

      end

      def validate_inclusion_of(attr, options = { })

      end

      def validate_length_of(attr, options = { })
        Spec::Rails::Matchers::ValidatesLengthOf.new(attr, options)
      end
      alias_method :validate_size_of, :validate_length_of

      def have_association(type, name, options = {})
        Spec::Rails::Matchers::AssociationMatcher.new(type, name, options)
      end

      def belong_to(name, options = {})
        Spec::Rails::Matchers::AssociationMatcher.new(:belongs_to, name, options)
      end

      def have_one(name, options = {})
        Spec::Rails::Matchers::AssociationMatcher.new(:has_one, name, options)
      end

      def have_many(name, options = {})
        Spec::Rails::Matchers::AssociationMatcher.new(:has_many, name, options)
      end

      def have_and_belong_to_many(name, options = {})
        Spec::Rails::Matchers::AssociationMatcher.new(:has_and_belongs_to_many, name, options)
      end
      
      def be_valid
        Spec::Rails::Matchers::BeValid.new
      end
      
    end
  end
end