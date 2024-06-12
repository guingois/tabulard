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

      def initialize(path)
        raise Error if path.nil?

        @roo = Roo::Excelx.new(path)

        worksheet = @roo.sheet_for(@roo.default_sheet)

        if worksheet.first_row
          init_with_filled_table(worksheet)
        else
          init_with_empty_table
        end
      end

      def each_header
        return to_enum(:each_header) { @cols_count } unless block_given?

        @cols_count.times do |col_index|
          col = @cols.name(col_index)

          cell_coords = [@rows.headers_coord, @cols.coord(col_index)]
          cell_value = @cells[cell_coords]&.value

          yield Header.new(col: col, value: cell_value)
        end

        self
      end

      def each_row
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
        @roo.close

        nil
      end

      private

      def init_with_filled_table(worksheet)
        @rows = Rows.new(
          first_row: worksheet.first_row,
          last_row: worksheet.last_row
        )

        @cols = Cols.new(
          first_col: worksheet.first_column,
          last_col: worksheet.last_column
        )

        @rows_count = @rows.count
        @cols_count = @cols.count

        @cells = worksheet.cells
      end

      def init_with_empty_table
        @rows_count = 0
        @cols_count = 0
      end

      class Rows
        def initialize(first_row:, last_row:)
          @headers_coord = first_row
          init(first_row.succ, last_row)
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
