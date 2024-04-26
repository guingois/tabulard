# frozen_string_literal: true

require_relative "../message_variant"

module Sheetah
  module Messaging
    module Messages
      class NoApplicableBackend < MessageVariant
        CODE = "no_applicable_backend"

        def_validator do
          sheet
          nil_code_data
        end
      end
    end
  end
end
