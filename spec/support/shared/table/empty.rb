# frozen_string_literal: true

require "tabulard/table"

RSpec.shared_examples "table/empty" do |sized_rows_enum: false|
  describe "#each_header" do
    context "with a block" do
      it "doesn't yield" do
        expect { |b| table.each_header(&b) }.not_to yield_control
      end

      it "returns self" do
        expect(table.each_header { double }).to be(table)
      end
    end

    context "without a block" do
      it "returns an enumerator" do
        enum = table.each_header

        expect(enum).to be_a(Enumerator)
        expect(enum.size).to eq(0)
        expect(enum.to_a).to eq([])
      end
    end
  end

  describe "#each_row" do
    context "with a block" do
      it "doesn't yield" do
        expect { |b| table.each_row(&b) }.not_to yield_control
      end

      it "returns self" do
        expect(table.each_row { double }).to be(table)
      end
    end

    context "without a block" do
      it "returns an enumerator" do
        enum = table.each_row

        expect(enum).to be_a(Enumerator)
        expect(enum.size).to eq(sized_rows_enum ? 0 : nil)
        expect(enum.to_a).to eq([])
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
    let(:headers_data) do
      %w[foo bar baz]
    end

    let(:table_opts) do
      super().merge(headers: headers_data)
    end

    it "relies on the custom headers" do
      headers = build_headers(headers_data)
      expect { |b| table.each_header(&b) }.to yield_successive_args(*headers)
    end
  end
end
