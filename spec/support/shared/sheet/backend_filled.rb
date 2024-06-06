# frozen_string_literal: true

require "sheetah/sheet"

RSpec.shared_examples "sheet/backend_filled" do
  unless instance_methods.include?(:source_data)
    alias_method :source_data, :source
  end

  describe "#each_header" do
    let(:headers) do
      build_headers(source_data[0])
    end

    context "with a block" do
      it "yields each header, with its letter-based index" do
        expect { |b| sheet.each_header(&b) }.to yield_successive_args(*headers)
      end

      it "returns self" do
        expect(sheet.each_header { double }).to be(sheet)
      end
    end

    context "without a block" do
      it "returns an enumerator" do
        enum = sheet.each_header

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
        expect { |b| sheet.each_row(&b) }.to yield_successive_args(*rows)
      end

      it "returns self" do
        expect(sheet.each_row { double }).to be(sheet)
      end
    end

    context "without a block" do
      it "returns an enumerator" do
        enum = sheet.each_row

        expect(enum).to be_a(Enumerator)
        expect(enum.size).to be_nil
        expect(enum.to_a).to eq(rows)
      end
    end
  end

  describe "#close" do
    it "returns nil" do
      expect(sheet.close).to be_nil
    end
  end
end
