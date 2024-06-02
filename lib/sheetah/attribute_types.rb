# frozen_string_literal: true

require_relative "attribute_types/scalar"
require_relative "attribute_types/composite"

module Sheetah
  module AttributeTypes
    # A factory for all {AttributeType}.
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

  # @!parse
  #  # The minimal interface of an {Attribute} type.
  #  # @abstract It only exists to document the interface implemented by the different classes of
  #  #   {AttributeTypes}.
  #  module AttributeType
  #    # A smarter version of `#initialize`, that will always return a frozen instance of the
  #    # type, with optional syntactic sugar for its arguments compared to `#initialize`.
  #    def self.build(*); end
  #
  #    # Given a type container, return the actual, usable type for the attribute.
  #    # @param container [Types::Container]
  #    # @return [Types::Type]
  #    def compile(container); end
  #
  #    # Enumerate the columns (one or more) that may compose the attribute in the tabular
  #    # document.
  #    #
  #    # @yieldparam index [Integer, nil]
  #    #   If there is only one column involved, then `index` will be `nil`. Otherwise, `index`
  #    #   will start at `0` and increase by `1` at each step.
  #    # @yieldparam required [Boolean]
  #    #   Whether the column must be present in the tabular document.
  #    #
  #    # @overload def each_column(&block)
  #    #   @return [self]
  #    # @overload def each_column
  #    #   @return [Enumerator]
  #    def each_column; end
  #  end
end
