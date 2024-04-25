# frozen_string_literal: true

require_relative "../message"

module Sheetah
  module Messaging
    module Messages
      class MustExist < Message
        CODE = "must_exist"

        def_validator do
          cell
          nil_code_data
        end
      end
    end
  end
end
