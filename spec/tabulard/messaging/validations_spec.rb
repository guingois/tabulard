# frozen_string_literal: true

require "tabulard/messaging/validations"

RSpec.describe Tabulard::Messaging::Validations do
  let(:message_class) do
    Struct.new(
      :code,
      :code_data,
      :scope,
      :scope_data,
      keyword_init: true
    )
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
    it "provides a kind of BaseValidator" do
      message_class.def_validator
      expect(message_class.validator).to be_a(described_class::BaseValidator)
    end

    it "may provide a different kind of validator" do
      message_class.def_validator(base: validator_class = Class.new)
      expect(message_class.validator).to be_a(validator_class)
    end

    it "validates" do
      message_class.def_validator { table }
      message = message_class.new(scope: "bar")
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
          message_subclass.def_validator(base: validator_class = Class.new)
          expect(message_subclass.validator).to be_a(validator_class)
        end
      end
    end
  end
end
