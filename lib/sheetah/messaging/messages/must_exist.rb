# frozen_string_literal: true

require_relative "../message_variant"

module Sheetah
  module Messaging
    module Messages
      class MustExist < MessageVariant
        CODE = "must_exist"

        def_validator do
          cell
          nil_code_data
        end
      end
    end
  end
end
