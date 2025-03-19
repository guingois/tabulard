# frozen_string_literal: true

require "sheetah/specification"
require "sheetah/column"

RSpec.describe Sheetah::Specification do
  describe "#get" do
    let(:header) do
      "foo"
    end

    let(:column0) do
      instance_double(Sheetah::Column, :column0, header_pattern: double(:pattern0))
    end

    let(:column1) do
      instance_double(Sheetah::Column, :column1, header_pattern: double(:pattern1))
    end

    let(:spec) do
      described_class.new(columns: [column0, column1])
    end

    before do
      allow(column0.header_pattern).to receive(:match?).with(anything).and_return(false)
      allow(column1.header_pattern).to receive(:match?).with(anything).and_return(false)
    end

    it "returns nil when header is nil" do
      expect(spec.get(nil)).to be_nil
    end

    it "may match with a pattern" do
      allow(column0.header_pattern).to receive(:match?).with(header).and_return(true)
      expect(spec.get(header)).to eq(column0)
    end

    it "may match with another pattern" do
      allow(column1.header_pattern).to receive(:match?).with(header).and_return(true)
      expect(spec.get(header)).to eq(column1)
    end

    it "may not match at all" do
      expect(spec.get(header)).to be_nil
    end
  end
end
