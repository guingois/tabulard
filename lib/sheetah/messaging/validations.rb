# frozen_string_literal: true

require_relative "validations/base_validator"

module Sheetah
  module Messaging
    module Validations
      module ClassMethods
        def def_validator(base: validator&.class || BaseValidator, &block)
          @validator = Class.new(base, &block).new.freeze
        end

        def validator
          if defined?(@validator)
            @validator
          elsif superclass.respond_to?(:validator)
            superclass.validator
          end
        end

        def validate(message)
          validator&.validate(message)
        end
      end

      def self.included(message_class)
        message_class.extend(ClassMethods)
      end

      def validate
        self.class.validate(self)
      end
    end
  end
end
