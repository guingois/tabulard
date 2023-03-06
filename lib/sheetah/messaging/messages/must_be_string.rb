# frozen_string_literal: true

require_relative "../message"

module Sheetah
  module Messaging
    module Messages
      class MustBeString < Message
        CODE = "must_be_string"
      end
    end
  end
end
