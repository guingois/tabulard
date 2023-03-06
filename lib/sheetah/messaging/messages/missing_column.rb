# frozen_string_literal: true

require_relative "../message"

module Sheetah
  module Messaging
    module Messages
      class MissingColumn < Message
        CODE = "missing_column"
      end
    end
  end
end
