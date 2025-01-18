# frozen_string_literal: true

require "tabulard/errors/error"

RSpec.describe Tabulard::Errors::Error do
  it "is some kind of StandardError" do
    expect(described_class).to have_attributes(superclass: StandardError)
  end
end
