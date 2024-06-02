# frozen_string_literal: true

require "sheetah/attribute"

RSpec.describe Sheetah::Attribute do
  describe "::build" do
    it "freezes the resulting instance" do
      attribute = described_class.build(key: :foo, type: :bar)
      expect(attribute).to be_frozen
    end
  end
end
