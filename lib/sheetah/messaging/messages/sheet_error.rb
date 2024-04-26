# frozen_string_literal: true

require_relative "../message_variant"

module Sheetah
  module Messaging
    module Messages
      class SheetError < MessageVariant
        CODE = "sheet_error"

        def_validator do
          sheet
          nil_code_data
        end
      end
    end
  end
end
