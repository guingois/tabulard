# frozen_string_literal: true

require "tabulard/messaging"

RSpec.describe Tabulard::Messaging do
  around do |example|
    config = described_class.config
    example.run
    described_class.config = config
  end

  describe "::config" do
    it "reads a global, frozen instance" do
      expect(described_class.config).to be_a(described_class::Config) & be_frozen
    end
  end

  describe "::config=" do
    it "writes a global instance" do
      described_class.config = (config = double)
      expect(described_class.config).to eq(config)
    end
  end

  describe "::configure" do
    let(:old) { described_class::Config.new }
    let(:new) { described_class::Config.new }

    before do
      described_class.config = old
      allow(old).to receive(:dup).and_return(new)
    end

    it "modifies a copy of the global instance" do
      expect do |b|
        described_class.configure(&b)
      end.to yield_with_args(new)

      expect(described_class.config).to be(new)
    end
  end
end
