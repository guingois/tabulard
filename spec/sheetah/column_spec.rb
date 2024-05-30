# frozen_string_literal: true

require "sheetah/column"

RSpec.describe Sheetah::Column do
  let(:key) { double }
  let(:type) { double }
  let(:index) { double }
  let(:header) { double }
  let(:header_pattern) { Object.new }
  let(:required) { false }

  let(:col) do
    described_class.new(
      key: key,
      type: type,
      index: index,
      header: header,
      header_pattern: header_pattern,
      required: required
    )
  end

  describe "#key" do
    it "reads the attribute" do
      expect(col.key).to be(key)
    end
  end

  describe "#type" do
    it "reads the attribute" do
      expect(col.type).to be(type)
    end
  end

  describe "#index" do
    it "reads the attribute" do
      expect(col.index).to be(index)
    end
  end

  describe "#header" do
    it "reads the attribute" do
      expect(col.header).to be(header)
    end
  end

  describe "#header_pattern" do
    it "reads the attribute" do
      expect(col.header_pattern).to be(header_pattern)
    end
  end

  describe "#required?" do
    it "reads the attribute" do
      expect(col.required?).to be(required)
    end
  end
end
