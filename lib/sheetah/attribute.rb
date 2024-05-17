# frozen_string_literal: true

require_relative "column"

module Sheetah
  class Attribute
    def initialize(key:, type:)
      @key = key
      @type = AttributeTypes.build(type)
    end

    attr_reader :key, :type

    def each_column(config)
      return enum_for(:each_column, config) unless block_given?

      compiled_type = type.compile(config.types)

      type.each_column do |index, required|
        header, header_pattern = config.header(key, index)

        yield Column.new(
          key: key,
          type: compiled_type,
          index: index,
          header: header,
          header_pattern: header_pattern,
          required: required
        )
      end
    end

    def freeze
      type.freeze
      super
    end
  end

  module AttributeTypes
    def self.build(type)
      case type
      when Hash
        Composite.new(**type)
      when Array
        Composite.new(composite: :array, scalars: type)
      else
        Scalar.new(type)
      end
    end

    class Value
      def initialize(type)
        @required = type.end_with?("!")
        @type = (@required ? type.slice(0..-2) : type).to_sym
      end

      attr_reader :type, :required
    end

    class Scalar
      def initialize(value)
        @value = Value.new(value)
      end

      def compile(container)
        container.scalar(@value.type)
      end

      def each_column
        return enum_for(:each_column) { 1 } unless block_given?

        yield nil, @value.required

        self
      end

      def freeze
        @value.freeze
        super
      end
    end

    class Composite
      def initialize(composite:, scalars:)
        @composite_type = composite
        @values = scalars.map { |scalar| Value.new(scalar) }
      end

      def compile(container)
        container.composite(@composite_type, @values.map(&:type))
      end

      def each_column
        return enum_for(:each_column) { @values.size } unless block_given?

        @values.each_with_index do |value, index|
          yield index, value.required
        end

        self
      end

      def freeze
        @values.freeze
        @values.each(&:freeze)
        super
      end
    end
  end

  private_constant :AttributeTypes
end
