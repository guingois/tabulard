# frozen_string_literal: true

module Sheetah
  module AttributeTypes
    class Value
      def self.build(type)
        required = type.end_with?("!")
        type = (required ? type.slice(0..-2) : type).to_sym

        value = new(type: type, required: required)
        value.freeze
      end

      def initialize(type:, required: false)
        @type = type
        @required = required
      end

      attr_reader :type, :required

      def ==(other)
        other.is_a?(self.class) &&
          type == other.type &&
          required == other.required
      end
    end
  end
end
