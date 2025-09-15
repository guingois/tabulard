# frozen_string_literal: true

require_relative "../message_variant"

module Tabulard
  module Messaging
    module Messages
      class MustBeArray < MessageVariant
        CODE = "tabulard.must_be_array"

        def_validator do
          cell
          nil_code_data
        end
      end
    end
  end
end
