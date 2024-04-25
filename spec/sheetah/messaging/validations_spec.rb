# frozen_string_literal: true

require "sheetah/messaging/validations"

RSpec.describe Sheetah::Messaging::Validations do
  let(:message_class) do
    Struct.new(
      :code,
      :code_data,
      :scope,
      :scope_data,
      keyword_init: true
    ) do
      def self.code
        "foo"
      end
    end
  end

  before do
    message_class.include(described_class)
  end

  it "doesn't define a validator by default" do
    expect(message_class.validator).to be_nil
  end

  it "doesn't validate by default" do
    message = double
    expect { message_class.validate(message) }.not_to raise_error
  end

  it "delegates instance validations to the class" do
    message = message_class.new
    allow(message_class).to receive(:validate).with(message).and_return(result = double)
    expect(message.validate).to eq(result)
  end

  context "when a validator is defined" do
    it "provides a kind of CodeClassMessageValidator" do
      message_class.def_validator
      expect(message_class.validator).to be_a(described_class::CodeClassMessageValidator)
    end

    it "may provide a different kind of validator" do
      message_class.def_validator(base: described_class::BaseValidator)
      expect(message_class.validator).to be_a(described_class::BaseValidator)
    end

    it "validates" do
      message_class.def_validator
      message = message_class.new(code: "bar")
      expect { message_class.validate(message) }.to raise_error(described_class::InvalidMessage)
    end

    context "when a message class is inherited" do
      let(:message_subclass) do
        Class.new(message_class)
      end

      before do
        message_class.def_validator
      end

      it "provides the validator from the superclass" do
        expect(message_subclass.validator).to be(message_class.validator)
      end

      context "when the subclass defines its own validator" do
        it "implicitly inherits from the superclass validator" do
          message_subclass.def_validator
          expect(message_subclass.validator).to be_a(message_class.validator.class)
        end

        it "may inherit from another validator class" do
          message_subclass.def_validator(base: described_class::BaseValidator)
          expect(message_subclass.validator).to be_a(described_class::BaseValidator)
        end
      end
    end
  end
end
