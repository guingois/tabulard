# frozen_string_literal: true

require "sheetah/messaging/messages/no_applicable_backend"

RSpec.describe Sheetah::Messaging::Messages::NoApplicableBackend do
  it "has a default code" do
    expect(described_class.new).to have_attributes(code: described_class::CODE)
  end
end
