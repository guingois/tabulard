# frozen_string_literal: true

require "tabulard/attribute"

RSpec.describe Tabulard::Attribute do
  describe "::build" do
    it "freezes the resulting instance" do
      attribute = described_class.build(key: :foo, type: :bar)
      expect(attribute).to be_frozen
    end
  end
end
