# frozen_string_literal: true

require_relative "attribute_types/scalar"
require_relative "attribute_types/composite"

module Sheetah
  module AttributeTypes
    def self.build(type)
      if type.is_a?(Hash) && type.key?(:composite)
        Composite.build(**type)
      elsif type.is_a?(Array)
        Composite.build(composite: :array, scalars: type)
      else
        Scalar.build(type)
      end
    end
  end
end
