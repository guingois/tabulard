# frozen_string_literal: true

require "sheetah/messaging/config"
require "climate_control"

RSpec.describe Sheetah::Messaging::Config do
  def envmod(envval, &block)
    ClimateControl.modify(envvar => envval, &block)
  end

  describe "#validate_messages" do
    let(:envvar) { "SHEETAH_MESSAGING_VALIDATE_MESSAGES" }

    it "is true by default" do
      config = envmod(nil) { described_class.new }
      expect(config.validate_messages).to be(true)
    end

    context "when the ENV says true" do
      it "is implicitly true" do
        config = envmod("true") { described_class.new }
        expect(config.validate_messages).to be(true)
      end

      it "may explicitly be false" do
        config = envmod("true") { described_class.new(validate_messages: false) }
        expect(config.validate_messages).to be(false)
      end
    end

    context "when the ENV says false" do
      it "is implicitly false" do
        config = envmod("false") { described_class.new }
        expect(config.validate_messages).to be(false)
      end

      it "may explicitly be true" do
        config = envmod("false") { described_class.new(validate_messages: true) }
        expect(config.validate_messages).to be(true)
      end
    end
  end

  describe "#validate_messages=" do
    it "can become true" do
      config = described_class.new(validate_messages: false)
      config.validate_messages = true
      expect(config.validate_messages).to be(true)
    end

    it "can become false" do
      config = described_class.new(validate_messages: true)
      config.validate_messages = false
      expect(config.validate_messages).to be(false)
    end
  end
end
