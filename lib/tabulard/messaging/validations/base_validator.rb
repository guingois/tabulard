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
    end
  end
end
