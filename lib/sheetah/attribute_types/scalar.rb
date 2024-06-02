# frozen_string_literal: true

require_relative "value"

module Sheetah
  module AttributeTypes
    # @see AttributeType
    class Scalar
      # @!parse
      #   include AttributeType

      # A smarter version of {#initialize}.
      #
      # - It automatically freezes the instance before returning it.
      # - It instantiates and injects a value automatically by passing the arguments to
      #   {Value.build}.
      #
      # The method signature is identical to the one of {Value.build}.
      #
      # @return [Scalar] a frozen instance
      def self.build(...)
        value = Value.build(...)

        scalar = new(value)
        scalar.freeze
      end

      # @param value [Value] The value of the scalar.
      # @see .build
      def initialize(value)
        @value = value
      end

      # @see AttributeType#compile
      def compile(container)
        container.scalar(value.type)
      end

      # @see AttributeType#each_column
      def each_column
        return enum_for(:each_column) { 1 } unless block_given?

        yield nil, value.required

        self
      end

      def ==(other)
        other.is_a?(self.class) &&
          value == other.value
      end

      protected

      attr_reader :value
    end
  end
end
