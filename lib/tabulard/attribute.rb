# frozen_string_literal: true

require_relative "attribute_types"
require_relative "column"

module Tabulard
  # The main building block of a {Template}.
  class Attribute
    # A smarter version of {#initialize}.
    #
    # - It automatically freezes the instance before returning it.
    # - It instantiates and injects a type automatically by passing the arguments to
    #   {AttributeTypes.build}.
    #
    # @return [Attribute] a frozen instance
    def self.build(key:, type:)
      type = AttributeTypes.build(type)

      attribute = new(key: key, type: type)
      attribute.freeze
    end

    # @param key [String, Symbol] The key in the resulting Hash after processing a row.
    # @param type [AttributeType] The type of the value.
    def initialize(key:, type:)
      @key = key
      @type = type
    end

    # @return [Symbol, String]
    attr_reader :key

    # An abstract specification of the type of a value in the resulting hash.
    #
    # It will be used to produce the {Types::Type concrete type} of a column (or a list of columns)
    # when a {TemplateConfig} is {Template#apply applied} to the {Template} owning the attribtue.
    #
    # @return [AttributeType]
    attr_reader :type

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
  end
end
