# frozen_string_literal: true

require "sheetah/template"

RSpec.describe Sheetah::Template do
  describe "::build" do
    it "freezes the resulting instance" do
      template = described_class.build(attributes: [])
      expect(template).to be_frozen
    end
  end
end
