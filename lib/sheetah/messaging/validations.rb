# frozen_string_literal: true

require_relative "../errors/error"
require_relative "constants"

module Sheetah
  module Messaging
    module Validations
      class InvalidMessage < Errors::Error
      end

      module DSL
        def cell
          include CellValidations
        end

        def col
          include ColValidations
        end

        def row
          include RowValidations
        end

        def sheet
          include SheetValidations
        end

        def nil_code_data
          include NilCodeData
        end
      end

      module CellValidations
        def validate_scope(message)
          message.scope == SCOPES::CELL
        end

        def validate_scope_data(message)
          message.scope_data in { col: String, row: Integer }
        end
      end

      module ColValidations
        def validate_scope(message)
          message.scope == SCOPES::COL
        end

        def validate_scope_data(message)
          message.scope_data in { col: String }
        end
      end

      module RowValidations
        def validate_scope(message)
          message.scope == SCOPES::ROW
        end

        def validate_scope_data(message)
          message.scope_data in { row: Integer }
        end
      end

      module SheetValidations
        def validate_scope(message)
          message.scope == SCOPES::SHEET
        end

        def validate_scope_data(message)
          message.scope_data.nil?
        end
      end

      module NilCodeData
        def validate_code_data(message)
          message.code_data.nil?
        end
      end

      class BaseValidator
        extend DSL

        def validate(message)
          errors = []

          errors << "code"       unless validate_code(message)
          errors << "code_data"  unless validate_code_data(message)
          errors << "scope"      unless validate_scope(message)
          errors << "scope_data" unless validate_scope_data(message)

          return if errors.empty?

          raise InvalidMessage, "#{errors.join(", ")} <#{message.class}>#{message.to_h}"
        end

        def validate_code(_message)
          true
        end

        def validate_code_data(_message)
          true
        end

        def validate_scope(_message)
          true
        end

        def validate_scope_data(_message)
          true
        end
      end

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
