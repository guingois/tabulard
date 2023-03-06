# frozen_string_literal: true

require "sheetah/messaging/messages/cleaned_string"

RSpec.describe Sheetah::Messaging::Messages::CleanedString do
  it "has a default code" do
    expect(described_class.new).to have_attributes(code: described_class::CODE)
  end
end
