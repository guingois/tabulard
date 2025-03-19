# frozen_string_literal: true

module Tabulard
  class Column
    def initialize(
      key:,
      type:,
      index:,
      header:,
      header_pattern:,
      required:
    )
      @key            = key
      @type           = type
      @index          = index
      @header         = header
      @header_pattern = header_pattern
      @required       = required
    end

    attr_reader :key,
                :type,
                :index,
                :header,
                :header_pattern

    def required?
      @required
    end
  end
end
