# frozen_string_literal: true

require_relative "value"

module Sheetah
  module AttributeTypes
    class Composite
      def initialize(composite:, scalars:)
        @composite_type = composite
        @values = scalars.map { |scalar| Value.new(scalar) }
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

      def freeze
        values.freeze
        values.each(&:freeze)
        super
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
