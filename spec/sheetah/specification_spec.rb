# frozen_string_literal: true

require "sheetah/specification"

RSpec.describe Sheetah::Specification do
  let(:spec) do
    described_class.new(columns: columns)
  end

  describe "#get" do
    let(:regexp_pattern) do
      /foo\d{3}bar/i
    end

    let(:string_pattern) do
      "Doubitchou"
    end

    let(:other_pattern) do
      double
    end

    let(:columns) do
      [
        instance_double(Sheetah::Column, :string, header_pattern: string_pattern),
        instance_double(Sheetah::Column, :regexp, header_pattern: regexp_pattern),
        instance_double(Sheetah::Column, :other, header_pattern: other_pattern),
      ]
    end

    it "returns nil when header is nil" do
      expect(spec.get(nil)).to be_nil
    end

    context "with a Regexp pattern" do
      it "returns the matching column" do
        expect(spec.get("foo123bar")).to eq(columns[1])
        expect(spec.get("Foo480BAR")).to eq(columns[1])
      end
    end

    context "with a String pattern" do
      it "returns the matching column" do
        expect(spec.get("Doubitchou")).to eq(columns[0])
      end

      it "matches case-sensitively" do
        expect(spec.get("doubitchou")).to be_nil
      end
    end

    context "with any other pattern" do
      let(:header) { "boudoudou" }

      it "matches an equivalent header" do
        allow(other_pattern).to receive(:===).with(header).and_return(true)
        expect(spec.get(header)).to eq(columns[2])
      end

      it "doesn't match a non-equivalent header" do
        allow(other_pattern).to receive(:===).with(header).and_return(false)
        expect(spec.get(header)).to be_nil
      end
    end

    context "when frozen" do
      it "can get existing patterns" do
        spec.freeze

        expect(spec.get("Doubitchou")).to eq(columns[0])
      end
    end
  end
end
