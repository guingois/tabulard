# frozen_string_literal: true

require_relative "../message"

module Sheetah
  module Messaging
    module Messages
      class SheetError < Message
        CODE = "sheet_error"

        def_validator do
          sheet
          nil_code_data
        end
      end
    end
  end
end
