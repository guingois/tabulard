# frozen_string_literal: true

require "tabulard/sheet"

RSpec.shared_context "sheet/factories" do
  def build_header(...)
    Tabulard::Sheet::Header.new(...)
  end

  def build_row(...)
    Tabulard::Sheet::Row.new(...)
  end

  def build_cell(...)
    Tabulard::Sheet::Cell.new(...)
  end

  def build_headers(values, col: "A")
    first_col_index = Tabulard::Sheet.col2int(col)

    values.map.with_index(first_col_index) do |value, col_index|
      build_header(col: Tabulard::Sheet.int2col(col_index), value: value)
    end
  end

  def build_cells(values, row:, col: "A")
    first_col_index = Tabulard::Sheet.col2int(col)

    values.map.with_index(first_col_index) do |value, col_index|
      build_cell(row: row, col: Tabulard::Sheet.int2col(col_index), value: value)
    end
  end

  def build_rows(list_of_values, row: 2, col: "A")
    list_of_values.map.with_index(row) do |values, row_index|
      value = build_cells(values, row: row_index, col: col)

      build_row(row: row_index, value: value)
    end
  end
end
