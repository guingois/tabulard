# frozen_string_literal: true

require_relative "value"

module Sheetah
  module AttributeTypes
    class Scalar
      def self.build(...)
        value = Value.build(...)

        scalar = new(value)
        scalar.freeze
      end

      def initialize(value)
        @value = value
      end

      def compile(container)
        container.scalar(value.type)
      end

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
