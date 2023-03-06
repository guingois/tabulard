# frozen_string_literal: true

require_relative "../message"

module Sheetah
  module Messaging
    module Messages
      class MustBeDate < Message
        CODE = "must_be_date"
      end
    end
  end
end
