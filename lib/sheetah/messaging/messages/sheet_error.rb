# frozen_string_literal: true

require_relative "../message"

module Sheetah
  module Messaging
    module Messages
      class SheetError < Message
        CODE = "sheet_error"
      end
    end
  end
end
