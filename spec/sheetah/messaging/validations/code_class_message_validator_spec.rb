# frozen_string_literal: true

require "sheetah/messaging/validations"

RSpec.describe Sheetah::Messaging::Validations::CodeClassMessageValidator do
  let(:validator) do
    described_class.new
  end

  let(:message_class) do
    Class.new(Sheetah::Messaging::Message) do
      def self.code
        "foo"
      end
    end
  end

  it "behaves like a BaseValidator" do
    expect(validator).to be_a(Sheetah::Messaging::Validations::BaseValidator)
  end

  context "when validating a message code" do
    it "validates the code from the message class" do
      msg1 = message_class.new(code: "foo")
      msg2 = message_class.new(code: "bar")
      expect(validator.validate_code(msg1)).to be true
      expect(validator.validate_code(msg2)).to be false
    end
  end
end
