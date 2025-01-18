# frozen_string_literal: true

require "tabulard/template_config"

RSpec.describe Tabulard::TemplateConfig do
  let(:config) { described_class.new }

  describe "#header" do
    it "produces a safe pattern from a header with special characters" do
      header, pattern = config.header(".*", nil)

      expect(pattern).to match(header)
      expect(pattern).not_to match("foo")
    end

    it "produces a case-insensitive pattern" do
      header, pattern = config.header(:foo, nil)

      expect(pattern).to match(header.downcase)
      expect(pattern).to match(header.upcase)
    end

    it "produces a strict pattern" do
      header, pattern = config.header(:foo, nil)

      expect(pattern).not_to match("#{header}foo")
      expect(pattern).not_to match("foo#{header}")
    end

    context "when the index is nil" do
      it "capitalizes the key" do
        header, = config.header(:foo, nil)

        expect(header).to eq("Foo")
      end
    end

    context "when the index is not nil" do
      it "capitalizes the key and appends a 1-based index" do
        header, = config.header(:foo, 3)

        expect(header).to eq("Foo 4")
      end
    end
  end
end
