# frozen_string_literal: true

require_relative "../message_variant"

module Sheetah
  module Messaging
    module Messages
      class MustBeEmail < MessageVariant
        CODE = "must_be_email"

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
