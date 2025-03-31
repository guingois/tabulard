# frozen_string_literal: true

require "tabulard/attribute_types/scalar"
require "tabulard/attribute_types/value"

RSpec.describe Tabulard::AttributeTypes::Scalar do
  describe "::build" do
    it "freezes the resulting instance" do
      type = described_class.build(:foo)
      expect(type).to be_frozen
    end
  end

  describe "#each_column" do
    let(:value) do
      instance_double(Tabulard::AttributeTypes::Value)
    end

    let(:scalar) do
      described_class.new(value)
    end

    context "without a block" do
      it "returns a sized enumerator" do
        enum = scalar.each_column
        expect(enum).to be_a(Enumerator)
        expect(enum.size).to eq(1)
      end
    end
  end
end
