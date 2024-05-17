# frozen_string_literal: true

require_relative "attribute_types"
require_relative "column"

module Sheetah
  class Attribute
    def self.build(key:, type:)
      type = AttributeTypes.build(type)

      attribute = new(key: key, type: type)
      attribute.freeze
    end

    def initialize(key:, type:)
      @key = key
      @type = type
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
  end
end
