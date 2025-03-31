# frozen_string_literal: true

require "tabulard/attribute"

RSpec.describe Tabulard::Attribute do
  describe "::build" do
    it "freezes the resulting instance" do
      attribute = described_class.build(key: :foo, type: :bar)
      expect(attribute).to be_frozen
    end
  end

  describe "#each_column" do
    let(:key) do
      :foo
    end

    let(:type) do
      :bar
    end

    let(:attribute) do
      described_class.new(key: key, type: type)
    end

    context "without a block" do
      let(:config) { double }

      it "returns an unsized enumerator" do
        enum = attribute.each_column(config)
        expect(enum).to be_a(Enumerator)
        expect(enum.size).to be_nil
      end
    end
  end
end
