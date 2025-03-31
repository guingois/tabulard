# frozen_string_literal: true

require "tabulard/template"
require "tabulard/attribute"
require "tabulard/errors/spec_error"

RSpec.describe Tabulard::Template do
  let(:attributes_args) do
    [
      { key: :key0, type: :type0 },
      { key: :key1, type: :type1 },
    ]
  end

  let(:attributes) do
    attributes_args.map do |args|
      Tabulard::Attribute.build(**args)
    end
  end

  it "doesn't ignore unspecified columns by default" do
    template = described_class.new(attributes: attributes, ignore_unspecified_columns: false)
    expect(template).to eq(described_class.new(attributes: attributes))
  end

  context "when an attribute is duplicated" do
    it "can't be initialized" do
      expect do
        described_class.new(attributes: [attributes[0], attributes[0]])
      end.to raise_error(Tabulard::Errors::SpecError, "Duplicated key: :key0")
    end
  end

  describe "::build" do
    it "simplifies initialization" do
      template = described_class.build(attributes: attributes_args)
      expect(template).to eq(described_class.new(attributes: attributes))
    end

    it "freezes the resulting instance" do
      template = described_class.build(attributes: attributes_args)
      expect(template).to be_frozen
    end
  end
end
