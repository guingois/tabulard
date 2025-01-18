# frozen_string_literal: true

require_relative "../../errors/error"

module Tabulard
  module Messaging
    module Validations
      class InvalidMessage < Errors::Error
      end
    end
  end
end
