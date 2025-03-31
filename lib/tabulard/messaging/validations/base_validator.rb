# frozen_string_literal: true

require_relative "dsl"
require_relative "invalid_message"

module Tabulard
  module Messaging
    module Validations
      class BaseValidator
        extend DSL

        def validate(message)
          errors = []

          validate_and_append_code(message, errors)
          validate_and_append_code_data(message, errors)
          validate_and_append_scope(message, errors)
          validate_and_append_scope_data(message, errors)

          return if errors.empty?

          raise InvalidMessage, build_exception_message(message, errors)
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

        private

        def validate_and_append_code(message, errors)
          errors << "code" unless validate_code(message)
        end

        def validate_and_append_code_data(message, errors)
          errors << "code_data" unless validate_code_data(message)
        end

        def validate_and_append_scope(message, errors)
          errors << "scope" unless validate_scope(message)
        end

        def validate_and_append_scope_data(message, errors)
          errors << "scope_data" unless validate_scope_data(message)
        end

        def build_exception_message(message, errors)
          "#{errors.join(", ")} <#{message.class}>#{message.to_h}"
        end
      end
    end
  end
end
