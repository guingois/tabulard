# frozen_string_literal: true

require "tabulard/types/composites/composite"
require "support/shared/composite_type"

RSpec.describe Tabulard::Types::Composites::Composite do
  include_examples "composite_type"

  it "inherits from the basic type" do
    expect(described_class.superclass).to be(Tabulard::Types::Type)
  end

  describe "::cast_classes" do
    it "is empty" do
      expect(described_class.cast_classes).to be_empty
    end
  end
end
