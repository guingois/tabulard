# frozen_string_literal: true

require_relative "../message"

module Sheetah
  module Messaging
    module Messages
      class MustBeBoolsy < Message
        CODE = "must_be_boolsy"
      end
    end
  end
end
