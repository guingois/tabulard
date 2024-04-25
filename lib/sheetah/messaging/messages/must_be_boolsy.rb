# frozen_string_literal: true

require_relative "../message"

module Sheetah
  module Messaging
    module Messages
      class MustBeBoolsy < Message
        CODE = "must_be_boolsy"

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
