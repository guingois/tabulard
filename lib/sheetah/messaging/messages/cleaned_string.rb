# frozen_string_literal: true

require_relative "../message"

module Sheetah
  module Messaging
    module Messages
      class CleanedString < Message
        CODE = "cleaned_string"

        def_validator do
          cell
          nil_code_data
        end
      end
    end
  end
end
