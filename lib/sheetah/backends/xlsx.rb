# frozen_string_literal: true

# NOTE: As reference:
# - {Roo::Excelx::Cell#cell_value} => the "raw" value before Excel's typecasts
# - {Roo::Excelx::Cell#value} => the "user" value, after Excel's typecasts
require "roo"

require_relative "../sheet"

module Sheetah
  module Backends
    class Xlsx
      include Sheet

      def initialize(path, **opts)
        super(**opts)

        @roo = Roo::Excelx.new(path)
        @worksheet = @roo.sheet_for(@roo.default_sheet)
        @is_empty = @worksheet.first_row.nil?
        @headers = detect_headers
        @cols_count = @headers.size
      end

      def each_header
        raise_if_closed

        return to_enum(:each_header) { @cols_count } unless block_given?

        @headers.each_with_index do |header, col_idx|
          col = Sheet.int2col(col_idx + 1)

          yield Header.new(col: col, value: header)
        end

        self
      end

      def each_row # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        raise_if_closed

        return to_enum(:each_row) unless block_given?
        return self if @is_empty

        first_row = @worksheet.first_row + 1
        last_row = @worksheet.last_row
        row = 0

        first_row.upto(last_row) do |cursor|
          raw = @worksheet.row(cursor)
          row += 1

          value = Array.new(@cols_count) do |col_idx|
            col = Sheet.int2col(col_idx + 1)

            Cell.new(row: row, col: col, value: raw[col_idx])
          end

          yield Row.new(row: row, value: value)
        end

        self
      end

      def close
        super do
          @roo.close
        end
      end

      private

      def detect_headers
        return [] if @is_empty

        @worksheet.row(@worksheet.first_row) || []
      end
    end
  end
end
