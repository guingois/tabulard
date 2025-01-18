# frozen_string_literal: true

require_relative "backends"
require_relative "headers"
require_relative "messaging"
require_relative "row_processor"
require_relative "sheet"
require_relative "sheet_processor_result"
require_relative "utils/monadic_result"

module Tabulard
  class SheetProcessor
    include Utils::MonadicResult

    def initialize(specification)
      @specification = specification
    end

    def call(*args, **opts, &block)
      messenger = Messaging::Messenger.new

      result = Backends.open(*args, **opts, messenger: messenger) do |sheet|
        process(sheet, messenger, &block)
      end

      handle_result(result, messenger)
    end

    private

    def parse_headers(sheet, messenger)
      headers = Headers.new(specification: @specification, messenger: messenger)

      sheet.each_header do |header|
        headers.add(header)
      end

      headers.result
    end

    def build_row_processor(sheet, messenger)
      parse_headers(sheet, messenger).bind do |headers|
        row_processor = RowProcessor.new(headers: headers, messenger: messenger)

        Success(row_processor)
      end
    end

    def process(sheet, messenger)
      build_row_processor(sheet, messenger).bind do |row_processor|
        sheet.each_row do |row|
          yield row_processor.call(row)
        end

        Success()
      end
    end

    def handle_result(result, messenger)
      SheetProcessorResult.new(result: result.discard, messages: messenger.messages)
    end
  end
end
