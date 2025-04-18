# frozen_string_literal: true

require "tabulard/types/scalars/boolsy"
require "support/shared/scalar_type"

RSpec.describe Tabulard::Types::Scalars::Boolsy do
  include_examples "scalar_type"

  it "inherits from the basic scalar type" do
    expect(described_class.superclass).to be(Tabulard::Types::Scalars::Scalar)
  end

  describe "::cast_classes" do
    it "extends the superclass' ones" do
      expect(described_class.cast_classes).to eq(
        described_class.superclass.cast_classes + [Tabulard::Types::Scalars::BoolsyCast]
      )
    end
  end
end
