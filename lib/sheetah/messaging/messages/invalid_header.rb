# frozen_string_literal: true

require_relative "../message"

module Sheetah
  module Messaging
    module Messages
      class InvalidHeader < Message
        CODE = "invalid_header"
      end
    end
  end
end
