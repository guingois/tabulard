# frozen_string_literal: true

require "sheetah/types/scalars/string"
require "support/shared/scalar_type"
require "support/shared/cast_class"

RSpec.describe Sheetah::Types::Scalars::String do
  include_examples "scalar_type"

  it "inherits from the basic scalar type" do
    expect(described_class.superclass).to be(Sheetah::Types::Scalars::Scalar)
  end

  describe "custom cast class" do
    subject(:cast_class) do
      described_class.cast_classes.last
    end

    it "is appended to the superclass' cast classes" do
      expect(
        described_class.superclass.cast_classes + [cast_class]
      ).to eq(described_class.cast_classes)
    end

    include_examples "cast_class"

    describe "#call" do
      before do
        allow(value).to receive(:is_a?).with(String).and_return(value_is_string)
      end

      context "when the value is a string" do
        let(:value_is_string) { true }

        it "is a success" do
          expect(cast.call(value, messenger)).to eq(value)
        end
      end

      context "when the value is not a string" do
        let(:value_is_string) { false }

        it "is a failure" do
          expect { cast.call(value, messenger) }.to throw_symbol(:failure, "must_be_string")
        end
      end
    end
  end
end
