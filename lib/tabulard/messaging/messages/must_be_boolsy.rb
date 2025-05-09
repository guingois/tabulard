# frozen_string_literal: true

require_relative "../message_variant"

module Tabulard
  module Messaging
    module Messages
      class MustBeBoolsy < MessageVariant
        CODE = "tabulard.must_be_boolsy"

        def_validator do
          cell

          def validate_code_data(message)
            message.code_data in { value: String }
          end
        end
      end
    end
  end
end
