# frozen_string_literal: true

require_relative "message"

module Tabulard
  module Messaging
    # While a {Message} represents any kind of message, {MessageVariant} represents any subset of
    # messages that share the same code.
    #
    # The code of a message variant can and should be defined at the class level, given that it
    # won't differ among the instances (and a validation is defined to enforce that invariant).
    # {MessageVariant} should be considered an abstract class, and its subclasses should define
    # their own `CODE` constant, which will be read by {.code}.
    #
    # As far as the other methods are concerned, {.code} should be considered the only source of
    # truth when it comes to reading the code assigned to a message variant. The fact that {.code}
    # is actually implemented using a dynamic resolution of the class' `CODE` constant is an
    # implementation detail stemming from the fact that documentation tools such as YARD will
    # highlight constants, as opposed to instance variables of a class for example. Using a constant
    # is therefore meant to provide better documentation, and it should not be relied upon
    # otherwise.
    #
    # @abstract
    class MessageVariant < Message
      # Reads the code assigned to the class (and its instances)
      # @return [String]
      def self.code
        self::CODE
      end

      # Simplifies the initialization of a variant
      #
      # Contrary to the requirements of {Message#initialize}, {MessageVariant.new} doesn't require
      # the caller to pass the `:code` keyword argument, as it is capable of prodividing it
      # automatically (from reading {.code}).
      def self.new(**opts)
        super(code: code, **opts)
      end

      def_validator do
        def validate_code(message)
          message.code == message.class.code
        end
      end
    end
  end
end
