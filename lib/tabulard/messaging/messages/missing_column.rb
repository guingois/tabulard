# frozen_string_literal: true

require_relative "../message_variant"

module Tabulard
  module Messaging
    module Messages
      class MissingColumn < MessageVariant
        CODE = "tabulard.missing_column"

        def_validator do
          table

          def validate_code_data(message)
            message.code_data in { value: String }
          end
        end
      end
    end
  end
end
