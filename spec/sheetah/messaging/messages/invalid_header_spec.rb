# frozen_string_literal: true

require "sheetah/messaging/messages/invalid_header"

RSpec.describe Sheetah::Messaging::Messages::InvalidHeader do
  it "has a default code" do
    expect(described_class.new).to have_attributes(code: described_class::CODE)
  end
end
