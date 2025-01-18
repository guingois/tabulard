# frozen_string_literal: true

require "tabulard/attribute_types/composite"

RSpec.describe Tabulard::AttributeTypes::Composite do
  describe "::build" do
    it "freezes the resulting instance" do
      type = described_class.build(composite: :foo, scalars: [:bar])
      expect(type).to be_frozen
    end
  end
end
