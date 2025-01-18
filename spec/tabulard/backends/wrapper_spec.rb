# frozen_string_literal: true

require "tabulard/backends/wrapper"
require "support/shared/table/factories"
require "support/shared/table/backend_empty"
require "support/shared/table/backend_filled"

RSpec.describe Tabulard::Backends::Wrapper do
  include_context "table/factories"

  let(:table_interface) do
    Module.new do
      def [](_); end
      def size; end
    end
  end

  let(:headers_interface) do
    Module.new do
      def [](_); end
      def size; end
    end
  end

  let(:values_interfaces) do
    Module.new do
      def [](_); end
    end
  end

  let(:input) do
    stub_input(source)
  end

  let(:table_opts) do
    {}
  end

  let(:table) do
    described_class.new(input, **table_opts)
  end

  def stub_input(source)
    input = instance_double(table_interface, size: source.size)

    source.each_with_index do |row, row_idx|
      input_row = stub_input_row(row, row_idx)

      allow(input).to receive(:[]).with(row_idx).and_return(input_row)
    end

    input
  end

  def stub_input_row(row, row_idx)
    input_row =
      if row_idx.zero?
        instance_double(headers_interface, size: row.size)
      else
        instance_double(values_interfaces)
      end

    row.each_with_index do |cell, col_idx|
      allow(input_row).to receive(:[]).with(col_idx).and_return(cell)
    end
  end

  after do |example|
    table.close unless example.metadata[:autoclose_table] == false
  end

  context "when the input table is empty" do
    let(:source) do
      []
    end

    include_examples "table/backend_empty", sized_rows_enum: true
  end

  context "when the input table is filled" do
    let(:source) do
      Array.new(4) do |row|
        Array.new(4) do |col|
          instance_double(Object, "(#{row},#{col})")
        end.freeze
      end.freeze
    end

    include_examples "table/backend_filled", sized_rows_enum: true
  end
end
