# frozen_string_literal: true

require_relative "attribute_types/scalar"
require_relative "attribute_types/composite"

module Sheetah
  module AttributeTypes
    def self.build(type)
      case type
      when Hash
        Composite.build(**type)
      when Array
        Composite.build(composite: :array, scalars: type)
      else
        Scalar.build(type)
      end
    end
  end
end
