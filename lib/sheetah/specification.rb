# frozen_string_literal: true

module Sheetah
  class Specification
    def initialize(columns:, ignore_unspecified_columns: false)
      @columns = columns
      @ignore_unspecified_columns = ignore_unspecified_columns
    end

    def get(header)
      return if header.nil?

      @columns.find do |column|
        column.header_pattern.match?(header)
      end
    end

    def required_columns
      @columns.select(&:required?)
    end

    def optional_columns
      @columns.reject(&:required?)
    end

    def ignore_unspecified_columns?
      @ignore_unspecified_columns
    end
  end
end
