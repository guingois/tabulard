# frozen_string_literal: true

require "tabulard/types/scalars/email"
require "support/shared/scalar_type"

RSpec.describe Tabulard::Types::Scalars::Email do
  include_examples "scalar_type"

  it "inherits from the scalar string type" do
    expect(described_class.superclass).to be(Tabulard::Types::Scalars::String)
  end

  describe "::cast_classes" do
    it "extends the superclass' ones" do
      expect(described_class.cast_classes).to eq(
        described_class.superclass.cast_classes + [Tabulard::Types::Scalars::EmailCast]
      )
    end
  end
end
