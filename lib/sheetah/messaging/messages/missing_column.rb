# frozen_string_literal: true

require_relative "../message_variant"

module Sheetah
  module Messaging
    module Messages
      class MissingColumn < MessageVariant
        CODE = "missing_column"

        def_validator do
          sheet

          def validate_code_data(message)
            message.code_data.is_a?(String)
          end
        end
      end
    end
  end
end
