# frozen_string_literal: true

require "tabulard/messaging"

Tabulard::Messaging.configure do |config|
  config.validate_messages = true
end
