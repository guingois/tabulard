# frozen_string_literal: true

require "sheetah/messaging/messages/duplicated_header"

RSpec.describe Sheetah::Messaging::Messages::DuplicatedHeader do
  it "has a default code" do
    expect(described_class.new).to have_attributes(code: described_class::CODE)
  end
end
