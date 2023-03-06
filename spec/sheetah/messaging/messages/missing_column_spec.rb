# frozen_string_literal: true

require "sheetah/messaging/messages/missing_column"

RSpec.describe Sheetah::Messaging::Messages::MissingColumn do
  it "has a default code" do
    expect(described_class.new).to have_attributes(code: described_class::CODE)
  end
end
