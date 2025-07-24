# frozen_string_literal: true

require "set"
require_relative "attribute"
require_relative "specification"
require_relative "errors/spec_error"

module Tabulard
  # A {Template} represents the abstract structure of a tabular document.
  #
  # The main component of the structure is the object obtained by processing a
  # row. A template therefore specifies all possible attributes of that object
  # as a list of (key, abstract type) pairs.
  #
  # Each attribute will eventually be compiled into as many concrete columns as
  # necessary with the help of a {TemplateConfig config} to produce a
  # {Specification specification}.
  #
  # In other words, a {Template} specifies the structure of the processing
  # result (its attributes), whereas a {Specification} specifies the columns
  # that may be involved into building the processing result.
  #
  # {Attribute Attributes} may either be _composite_ (their value is a
  # composition of multiple values) or _scalar_ (their value is a single
  # value). Scalar attributes will thus produce a single column in the
  # specification, and composite attributes will produce as many columns as
  # required by the number of scalar values they hold.
  class Template
    def self.build(attributes:, **)
      attributes = attributes.map { |attribute| Attribute.build(**attribute) }
      attributes.freeze

      template = new(attributes: attributes, **)
      template.freeze
    end

    def initialize(attributes:, ignore_unspecified_columns: false)
      ensure_attributes_unicity(attributes)

      @attributes = attributes
      @ignore_unspecified_columns = ignore_unspecified_columns
    end

    def apply(config)
      columns = []

      attributes.each do |attribute|
        attribute.each_column(config) do |column|
          columns << column.freeze
        end
      end

      specification = Specification.new(
        columns: columns.freeze,
        ignore_unspecified_columns: ignore_unspecified_columns
      )

      specification.freeze
    end

    def ==(other)
      other.is_a?(self.class) &&
        attributes == other.attributes &&
        ignore_unspecified_columns == other.ignore_unspecified_columns
    end

    protected

    attr_reader :attributes, :ignore_unspecified_columns

    private

    def ensure_attributes_unicity(attributes)
      keys = Set.new

      duplicate = attributes.find do |attribute|
        !keys.add?(attribute.key)
      end

      return unless duplicate

      raise Errors::SpecError, "Duplicated key: #{duplicate.key.inspect}"
    end
  end
end
