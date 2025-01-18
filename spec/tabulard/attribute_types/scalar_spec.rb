# frozen_string_literal: true

require "tabulard/attribute_types/scalar"

RSpec.describe Tabulard::AttributeTypes::Scalar do
  describe "::build" do
    it "freezes the resulting instance" do
      type = described_class.build(:foo)
      expect(type).to be_frozen
    end
  end
end
