# frozen_string_literal: true

require "tabulard/table"

RSpec.shared_examples "table/filled" do |sized_rows_enum: false|
  unless instance_methods.include?(:source_data)
    alias_method :source_data, :source
  end

  describe "#each_header" do
    let(:headers) do
      build_headers(source_data[0])
    end

    context "with a block" do
      it "yields each header, with its letter-based index" do
        expect { |b| table.each_header(&b) }.to yield_successive_args(*headers)
      end

      it "returns self" do
        expect(table.each_header { double }).to be(table)
      end
    end

    context "without a block" do
      it "returns an enumerator" do
        enum = table.each_header

        expect(enum).to be_a(Enumerator)
        expect(enum.size).to eq(headers.size)
        expect(enum.to_a).to eq(headers)
      end
    end
  end

  describe "#each_row" do
    let(:rows) do
      build_rows(source_data[1..])
    end

    context "with a block" do
      it "yields each row, with its integer-based index" do
        expect { |b| table.each_row(&b) }.to yield_successive_args(*rows)
      end

      it "returns self" do
        expect(table.each_row { double }).to be(table)
      end
    end

    context "without a block" do
      it "returns an enumerator" do
        enum = table.each_row

        expect(enum).to be_a(Enumerator)
        expect(enum.size).to eq(sized_rows_enum ? rows.size : nil)
        expect(enum.to_a).to eq(rows)
      end
    end
  end

  describe "#close" do
    it "returns nil" do
      expect(table.close).to be_nil
    end
  end

  context "when it is closed" do
    before { table.close }

    it "can't enumerate headers" do
      expect { table.each_header }.to raise_error(Tabulard::Table::ClosureError)
    end

    it "can't enumerate rows" do
      expect { table.each_row }.to raise_error(Tabulard::Table::ClosureError)
    end
  end

  context "when headers are customized" do
    let(:data_size) { source_data[0].size }
    let(:headers_size) { data_size + diff }

    let(:headers_data) do
      Array.new(headers_size) { |i| "header#{i}" }
    end

    let(:table_opts) do
      super().merge(headers: headers_data)
    end

    context "when their size is equal to the size of the data" do
      let(:diff) { 0 }

      it "relies on the custom headers" do
        headers = build_headers(headers_data)
        expect { |b| table.each_header(&b) }.to yield_successive_args(*headers)
      end

      it "treats all rows as data" do
        rows = build_rows(source_data, row: 1)
        expect { |b| table.each_row(&b) }.to yield_successive_args(*rows)
      end
    end

    context "when their size is smaller than the size of the data" do
      let(:diff) { -1 }

      it "fails to initialize", autoclose_table: false do
        expect { table }.to raise_error(
          Tabulard::Table::TooFewHeaders,
          "Expected #{data_size} headers, got: #{headers_size}"
        )
      end
    end

    context "when their size is larger than the size of the data" do
      let(:diff) { 1 }

      it "fails to initialize", autoclose_table: false do
        expect { table }.to raise_error(
          Tabulard::Table::TooManyHeaders,
          "Expected #{data_size} headers, got: #{headers_size}"
        )
      end
    end
  end
end
