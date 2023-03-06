# frozen_string_literal: true

require_relative "../message"

module Sheetah
  module Messaging
    module Messages
      class DuplicatedHeader < Message
        CODE = "duplicated_header"
      end
    end
  end
end
