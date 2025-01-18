# frozen_string_literal: true

require_relative "backends"
require_relative "headers"
require_relative "messaging"
require_relative "row_processor"
require_relative "table"
require_relative "table_processor_result"
require_relative "utils/monadic_result"

module Tabulard
  class TableProcessor
    include Utils::MonadicResult

    def initialize(specification)
      @specification = specification
    end

    def call(*args, **opts, &block)
      messenger = Messaging::Messenger.new

      result = Backends.open(*args, **opts, messenger: messenger) do |table|
        process(table, messenger, &block)
      end

      handle_result(result, messenger)
    end

    private

    def parse_headers(table, messenger)
      headers = Headers.new(specification: @specification, messenger: messenger)

      table.each_header do |header|
        headers.add(header)
      end

      headers.result
    end

    def build_row_processor(table, messenger)
      parse_headers(table, messenger).bind do |headers|
        row_processor = RowProcessor.new(headers: headers, messenger: messenger)

        Success(row_processor)
      end
    end

    def process(table, messenger)
      build_row_processor(table, messenger).bind do |row_processor|
        table.each_row do |row|
          yield row_processor.call(row)
        end

        Success()
      end
    end

    def handle_result(result, messenger)
      TableProcessorResult.new(result: result.discard, messages: messenger.messages)
    end
  end
end
