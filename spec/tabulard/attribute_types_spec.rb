# frozen_string_literal: true

require "tabulard/attribute_types"

RSpec.describe Tabulard::AttributeTypes do
  def build(...)
    described_class.build(...)
  end

  def value(...)
    Tabulard::AttributeTypes::Value.new(...)
  end

  def scalar(...)
    Tabulard::AttributeTypes::Scalar.new(...)
  end

  def composite(...)
    Tabulard::AttributeTypes::Composite.new(...)
  end

  context "when given a scalar as a Hash" do
    let(:type) do
      {
        type: :foo,
        required: false,
      }
    end

    it "has the expected type" do
      expect(build(type)).to eq(scalar(value(type: :foo, required: false)))
    end
  end

  context "when given a scalar as a Symbol" do
    let(:type) do
      :foo
    end

    it "has the expected type" do
      expect(build(type)).to eq(scalar(value(type: :foo, required: true)))
    end
  end

  context "when given a composite as a Hash" do
    let(:type) do
      {
        composite: :oof,
        scalars: [
          :foo,
          :bar?,
          { type: :baz, required: false },
        ],
      }
    end

    it "has the expected type and scalars" do
      expect(build(type)).to eq(
        composite(
          composite: :oof,
          scalars: [
            value(type: :foo, required: true),
            value(type: :bar, required: false),
            value(type: :baz, required: false),
          ]
        )
      )
    end
  end

  context "when given a composite as an Array" do
    let(:type) do
      [
        :foo,
        :bar?,
        { type: :baz, required: false },
      ]
    end

    it "has the expected type and scalars" do
      expect(build(type)).to eq(
        composite(
          composite: :array,
          scalars: [
            value(type: :foo, required: true),
            value(type: :bar, required: false),
            value(type: :baz, required: false),
          ]
        )
      )
    end
  end
end
