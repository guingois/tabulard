# frozen_string_literal: true

require_relative "../message"

module Sheetah
  module Messaging
    module Messages
      class MustBeEmail < Message
        CODE = "must_be_email"
      end
    end
  end
end
