# frozen_string_literal: true

require "tabulard/errors/spec_error"

RSpec.describe Tabulard::Errors::SpecError do
  it "is some kind of Error" do
    expect(described_class).to have_attributes(superclass: Tabulard::Errors::Error)
  end
end
