# frozen_string_literal: true

require_relative "value"

module Sheetah
  module AttributeTypes
    class Composite
      # A smarter version of {#initialize}.
      #
      # - It automatically freezes the instance before returning it.
      # - It instantiates, freezes and injects a list of values automatically by mapping the given
      #   list of scalars to a list of {Value values} using {Value.build}.
      #
      # @return [Composite] a frozen instance
      def self.build(composite:, scalars:)
        scalars = scalars.map { |scalar| Value.build(scalar) }
        scalars.freeze

        composite = new(composite: composite, scalars: scalars)
        composite.freeze
      end

      # @param composite [Symbol] The name used to refer to a composite type from a
      #   {Types::Container}.
      # @param scalars [Array<Value>] The list of values of the composite.
      # @see .build
      def initialize(composite:, scalars:)
        @composite_type = composite
        @values = scalars
      end

      def compile(container)
        container.composite(composite_type, values.map(&:type))
      end

      def each_column
        return enum_for(:each_column) { values.size } unless block_given?

        values.each_with_index do |value, index|
          yield index, value.required
        end

        self
      end

      def ==(other)
        other.is_a?(self.class) &&
          composite_type == other.composite_type &&
          values == other.values
      end

      protected

      attr_reader :composite_type, :values
    end
  end
end
