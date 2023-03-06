# frozen_string_literal: true

require_relative "../message"

module Sheetah
  module Messaging
    module Messages
      class NoApplicableBackend < Message
        CODE = "no_applicable_backend"
      end
    end
  end
end
