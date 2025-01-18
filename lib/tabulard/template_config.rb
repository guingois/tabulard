# frozen_string_literal: true

require_relative "types/container"

module Tabulard
  class TemplateConfig
    def initialize(types: Types::Container.new)
      @types = types
    end

    attr_reader :types

    # Given an attribute key and a possibily-nil column index, return the header and header pattern
    # for that column.
    #
    # The return value should be an array with two items:
    #
    # 1. The first item is the header, as a String.
    # 2. The second item is the header pattern, and should respond to `#match?` with a boolean
    #     value. Instances of Regexp will obviously do, but the requirement is really about the
    #     `#match?` method.
    #
    # @param key [Symbol, String]
    # @param index [Integer, nil]
    # @return [Array(String, #match?)]
    def header(key, index)
      header = key.to_s.capitalize
      header = "#{header} #{index + 1}" if index

      pattern = /^#{Regexp.escape(header)}$/i

      [header, pattern]
    end
  end
end
