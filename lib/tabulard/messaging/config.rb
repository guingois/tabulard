# frozen_string_literal: true

module Tabulard
  module Messaging
    class Config
      def initialize(validate_messages: default_validate_messages)
        @validate_messages = validate_messages
      end

      attr_accessor :validate_messages

      private

      def default_validate_messages
        ENV["TABULARD_MESSAGING_VALIDATE_MESSAGES"] != "false"
      end
    end
  end
end
