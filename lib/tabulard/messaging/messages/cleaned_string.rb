# frozen_string_literal: true

require_relative "../message_variant"

module Tabulard
  module Messaging
    module Messages
      class CleanedString < MessageVariant
        CODE = "tabulard.cleaned_string"

        def_validator do
          cell
          nil_code_data
        end
      end
    end
  end
end
