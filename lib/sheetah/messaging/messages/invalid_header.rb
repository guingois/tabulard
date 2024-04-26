# frozen_string_literal: true

require_relative "../message_variant"

module Sheetah
  module Messaging
    module Messages
      class InvalidHeader < MessageVariant
        CODE = "invalid_header"

        def_validator do
          col

          def validate_code_data(message)
            message.code_data.is_a?(String)
          end
        end
      end
    end
  end
end
