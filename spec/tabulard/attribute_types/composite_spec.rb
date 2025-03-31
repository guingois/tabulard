# frozen_string_literal: true

require "tabulard/attribute_types/composite"
require "tabulard/attribute_types/value"

RSpec.describe Tabulard::AttributeTypes::Composite do
  describe "::build" do
    it "freezes the resulting instance" do
      type = described_class.build(composite: :foo, scalars: [:bar])
      expect(type).to be_frozen
    end
  end

  describe "#each_column" do
    let(:composite_type) do
      :foo
    end

    let(:scalars) do
      [
        instance_double(Tabulard::AttributeTypes::Value),
        instance_double(Tabulard::AttributeTypes::Value),
      ]
    end

    let(:composite) do
      described_class.new(composite: composite_type, scalars: scalars)
    end

    context "without a block" do
      it "returns a sized enumerator" do
        enum = composite.each_column
        expect(enum).to be_a(Enumerator)
        expect(enum.size).to eq(scalars.size)
      end
    end
  end
end
