# frozen_string_literal: true

module Sheetah
  module AttributeTypes
    class Value
      def initialize(type)
        @required = type.end_with?("!")
        @type = (@required ? type.slice(0..-2) : type).to_sym
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
