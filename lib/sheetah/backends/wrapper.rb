# frozen_string_literal: true

require_relative "../sheet"

module Sheetah
  module Backends
    class Wrapper
      include Sheet

      def initialize(table, headers: nil, **opts)
        super(**opts)

        if (table_size = table.size).positive?
          init_with_filled_table(table, table_size: table_size, headers: headers)
        else
          init_with_empty_table(headers: headers)
        end
      end

      def each_header
        raise_if_closed

        return to_enum(:each_header) { @cols_count } unless block_given?

        @cols_count.times do |col_index|
          col, cell_value = read_cell(@headers, col_index)

          yield Header.new(col: col, value: cell_value)
        end

        self
      end

      def each_row
        raise_if_closed

        return to_enum(:each_row) { @rows_count } unless block_given?

        @rows_count.times do |row_index|
          row, row_data = read_row(row_index)

          row_value = Array.new(@cols_count) do |col_index|
            col, cell_value = read_cell(row_data, col_index)

            Cell.new(row: row, col: col, value: cell_value)
          end

          yield Row.new(row: row, value: row_value)
        end

        self
      end

      private

      def init_with_filled_table(table, table_size:, headers:)
        @table = table

        if headers
          ensure_compatible_size(table[0].size, headers.size)

          headers_row = -1
          @headers = headers
        else
          headers_row = 0
          @headers = table[headers_row]
        end

        @first_row = headers_row.succ
        @first_row_name = @first_row.succ
        @rows_count = table_size - @first_row

        @first_col = 0
        @first_col_name = @first_col.succ
        @cols_count = @headers.size
      end

      def init_with_empty_table(headers:)
        @rows_count = 0

        if headers
          @headers = headers
          @first_col = 0
          @first_col_name = @first_col.succ
          @cols_count = headers.size
        else
          @cols_count = 0
        end
      end

      def read_row(row_index)
        row = @first_row_name + row_index
        row_data = @table[@first_row + row_index]

        [row, row_data]
      end

      def read_cell(row_data, col_index)
        col = Sheet.int2col(@first_col_name + col_index)
        cell_value = row_data[@first_col + col_index]

        [col, cell_value]
      end
    end
  end
end
