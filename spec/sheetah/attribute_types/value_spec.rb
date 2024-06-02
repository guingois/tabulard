# frozen_string_literal: true

require "sheetah/attribute_types/value"

RSpec.describe Sheetah::AttributeTypes::Value do
  let(:type) do
    :foo
  end

  def newval(...)
    described_class.new(...)
  end

  def buildval(...)
    described_class.build(...)
  end

  describe "::build" do
    it "returns a frozen value" do
      value = buildval(type: type)
      expect(value).to be_frozen
    end

    context "when the type requirement is implicit" do
      it "has a required type" do
        value = buildval(type: type)
        expect(value).to eq(newval(type: type, required: true))
      end

      it "can be expressed with syntactic sugar" do
        value = buildval(type)
        expect(value).to eq(newval(type: type, required: true))
      end
    end

    context "when the type requirement is explicit" do
      it "may have an optional type" do
        value = buildval(type: type, required: false)
        expect(value).to eq(newval(type: type, required: false))
      end

      it "may have a required type" do
        value = buildval(type: type, required: true)
        expect(value).to eq(newval(type: type, required: true))
      end

      it "can be optional using syntactic sugar" do
        value = buildval(:"#{type}?")
        expect(value).to eq(newval(type: type, required: false))
      end
    end
  end
end
