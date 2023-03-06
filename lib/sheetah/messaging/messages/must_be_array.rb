# frozen_string_literal: true

require_relative "../message"

module Sheetah
  module Messaging
    module Messages
      class MustBeArray < Message
        CODE = "must_be_array"
      end
    end
  end
end
