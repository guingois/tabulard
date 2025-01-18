# frozen_string_literal: true

require_relative "../message_variant"

module Tabulard
  module Messaging
    module Messages
      class InvalidHeader < MessageVariant
        CODE = "tabulard.invalid_header"

        def_validator do
          col

          def validate_code_data(message)
            message.code_data in { value: String }
          end
        end
      end
    end
  end
end
