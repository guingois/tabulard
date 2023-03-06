# frozen_string_literal: true

require_relative "../message"

module Sheetah
  module Messaging
    module Messages
      class MustExist < Message
        CODE = "must_exist"
      end
    end
  end
end
