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

      def initialize(path, headers: nil, **opts)
        super(**opts)

        @roo = Roo::Excelx.new(path)

        worksheet = @roo.sheet_for(@roo.default_sheet)

        if worksheet.first_row
          init_with_filled_table(worksheet, headers: headers)
        else
          init_with_empty_table(headers: headers)
        end
      end

      def each_header(&block)
        raise_if_closed

        return to_enum(:each_header) { @cols_count } unless block
        return self if @cols_count.zero?

        if @headers
          each_custom_header(&block)
        else
          each_cell_header(&block)
        end

        self
      end

      def each_row
        raise_if_closed

        return to_enum(:each_row) unless block_given?

        @rows_count.times do |row_index|
          row = @rows.name(row_index)

          row_value = Array.new(@cols_count) do |col_index|
            col = @cols.name(col_index)

            cell_coords = [@rows.coord(row_index), @cols.coord(col_index)]
            cell_value = @cells[cell_coords]&.value

            Cell.new(row: row, col: col, value: cell_value)
          end

          yield Row.new(row: row, value: row_value)
        end

        self
      end

      def close
        super do
          @roo.close
        end
      end

      private

      def init_with_filled_table(worksheet, headers:)
        @rows = Rows.new(
          first_row: worksheet.first_row,
          last_row: worksheet.last_row,
          include_headers: headers.nil?
        )

        @cols = Cols.new(
          first_col: worksheet.first_column,
          last_col: worksheet.last_column
        )

        @rows_count = @rows.count
        @cols_count = @cols.count

        if (@headers = headers)
          ensure_compatible_size(@cols_count, @headers.size)
        end

        @cells = worksheet.cells
      end

      def init_with_empty_table(headers:)
        @rows = nil
        @rows_count = 0

        if headers
          @cols = Cols.new(first_col: 1, last_col: headers.size)
          @cols_count = @cols.count
        else
          @cols = nil
          @cols_count = 0
        end

        @headers = headers
        @cells = nil
      end

      def each_custom_header
        @headers.each_with_index do |value, col_index|
          col = @cols.name(col_index)

          yield Header.new(col: col, value: value)
        end
      end

      def each_cell_header
        @cols_count.times do |col_index|
          col = @cols.name(col_index)

          cell_coords = [@rows.headers_coord, @cols.coord(col_index)]
          cell_value = @cells[cell_coords]&.value

          yield Header.new(col: col, value: cell_value)
        end
      end

      class Rows
        def initialize(first_row:, last_row:, include_headers:)
          if include_headers
            @headers_coord = first_row
            init(first_row.succ, last_row)
          else
            @headers_coord = nil
            init(first_row, last_row)
          end
        end

        attr_reader :count, :headers_coord

        def name(row)
          @first_name + row
        end

        def coord(row)
          @first_row + row
        end

        private

        def init(first_row, last_row)
          offset = first_row - 1

          @first_row = first_row
          @first_name = first_row
          @count = last_row - offset
        end
      end

      class Cols
        def initialize(first_col:, last_col:)
          cols_offset = first_col - 1

          @first_col = first_col
          @first_name = first_col
          @count = last_col - cols_offset
        end

        attr_reader :count

        def name(col)
          Sheet.int2col(@first_name + col)
        end

        def coord(col)
          @first_col + col
        end
      end
    end
  end
end
