# frozen_string_literal: true

require_relative "../message_variant"

module Sheetah
  module Messaging
    module Messages
      class MustBeDate < MessageVariant
        CODE = "must_be_date"

        def_validator do
          cell

          def validate_code_data(message)
            message.code_data in { format: String }
          end
        end
      end
    end
  end
end
