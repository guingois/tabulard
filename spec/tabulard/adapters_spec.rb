# frozen_string_literal: true

require "tabulard/adapters"

RSpec.describe Tabulard::Adapters do
  describe "::open" do
    let(:adapter) do
      double
    end

    let(:foo) { double }
    let(:bar) { double }
    let(:res) { double }

    it "opens with a adapter" do
      allow(adapter).to receive(:open).with(foo, bar: bar).and_return(res)

      expect(described_class.open(foo, adapter: adapter, bar: bar)).to be(res)
    end

    it "may not open without a adapter" do
      expect { described_class.open(foo, bar: bar) }.to raise_error(
        ArgumentError, /missing keyword: :adapter/
      )
    end
  end
end
