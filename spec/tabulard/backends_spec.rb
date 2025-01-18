# frozen_string_literal: true

require "tabulard/backends"

RSpec.describe Tabulard::Backends do
  describe "::open" do
    let(:backend) do
      double
    end

    let(:foo) { double }
    let(:bar) { double }
    let(:res) { double }

    it "opens with a backend" do
      allow(backend).to receive(:open).with(foo, bar: bar).and_return(res)

      expect(described_class.open(foo, backend: backend, bar: bar)).to be(res)
    end

    it "may not open without a backend" do
      expect { described_class.open(foo, bar: bar) }.to raise_error(
        ArgumentError, /missing keyword: :backend/
      )
    end
  end
end
