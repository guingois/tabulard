# frozen_string_literal: true

require "tabulard/messaging/messages/must_exist"

RSpec.describe Tabulard::Messaging::Messages::MustExist do
  it "has a default code" do
    expect(described_class.new).to have_attributes(code: described_class::CODE)
  end

  describe "validations" do
    let(:message) do
      described_class.new(
        code: "must_exist",
        code_data: nil,
        scope: "CELL",
        scope_data: { col: "FOO", row: 42 }
      )
    end

    let(:validator) do
      described_class.validator
    end

    it "may be valid" do
      expect { message.validate }.not_to raise_error
    end

    it "may not have a different code" do
      message.code = "foo"
      expect(validator.validate_code(message)).to be false
    end

    it "may not have some code data" do
      message.code_data = { foo: :baz }
      expect(validator.validate_code_data(message)).to be false
    end

    it "may not have a different scope" do
      message.scope = "ROW"
      expect(validator.validate_scope(message)).to be false
    end

    it "may not have nil scope_data" do
      message.scope_data = nil
      expect(validator.validate_scope_data(message)).to be false
    end
  end
end
