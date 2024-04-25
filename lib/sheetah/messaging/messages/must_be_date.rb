# frozen_string_literal: true

require_relative "../message"

module Sheetah
  module Messaging
    module Messages
      class MustBeDate < Message
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
