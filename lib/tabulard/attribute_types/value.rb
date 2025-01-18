# frozen_string_literal: true

module Tabulard
  module AttributeTypes
    class Value
      # A smarter version of {#initialize}.
      #
      # - It automatically freezes the instance before returning it.
      # - It accepts two kinds of parameters: either those of {#initialize}, or a shortcut. See the
      #   overloaded method signature for details.
      #
      # @overload def build(type:, required:)
      #   @example
      #     Value.build(type: :foo, required: true)
      #   @see #initialize
      #
      # @overload def build(type)
      #   @param type [Symbol] The name of the type, optionally suffixed with `!` to indicate that
      #     the value is required.
      #   @example
      #     Value.build(:foo) #=> Value.build(type: :foo, required: false)
      #     Value.build(:foo!) #=> Value.build(type: :foo, required: true)
      #
      # @return [Value] a frozen instance
      def self.build(arg)
        value = arg.is_a?(Hash) ? new(**arg) : from_type_name(arg)
        value.freeze
      end

      def self.from_type_name(type)
        type = type.to_s

        optional = type.end_with?("?")
        type = (optional ? type.slice(0..-2) : type).to_sym

        new(type: type, required: !optional)
      end

      private_class_method :from_type_name

      # @param type [Symbol] The name used to refer to a scalar type from a {Types::Container}.
      # @param required [Boolean] Is the value required to be given in the input ?
      # @see .build
      def initialize(type:, required: true)
        @type = type
        @required = required
      end

      # @return [Symbol]
      attr_reader :type

      # @return [Boolean]
      attr_reader :required

      def ==(other)
        other.is_a?(self.class) &&
          type == other.type &&
          required == other.required
      end
    end
  end
end
