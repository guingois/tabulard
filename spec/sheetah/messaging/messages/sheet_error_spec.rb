# frozen_string_literal: true

require "sheetah/messaging/messages/sheet_error"

RSpec.describe Sheetah::Messaging::Messages::SheetError do
  it "has a default code" do
    expect(described_class.new).to have_attributes(code: described_class::CODE)
  end
end
