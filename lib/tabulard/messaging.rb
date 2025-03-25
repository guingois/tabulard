# frozen_string_literal: true

module Tabulard
  module Messaging
    require_relative "messaging/config"
    require_relative "messaging/constants"
    require_relative "messaging/message"
    require_relative "messaging/message_variant"
    require_relative "messaging/messenger"

    class << self
      attr_accessor :config

      def configure
        config = self.config.dup
        yield config
        self.config = config.freeze
      end
    end

    self.config = Config.new.freeze
  end
end
