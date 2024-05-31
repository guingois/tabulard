# frozen_string_literal: true

require_relative "attribute_types/scalar"
require_relative "attribute_types/composite"

module Sheetah
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
  end
end
