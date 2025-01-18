# frozen_string_literal: true

require "tabulard/messaging/validations"

RSpec.describe Tabulard::Messaging::Validations::BaseValidator do
  let(:validator_class) do
    described_class
  end

  let(:validator) do
    validator_class.new
  end

  let(:validation_error) do
    Tabulard::Messaging::Validations::InvalidMessage
  end

  let(:message_class) do
    Tabulard::Messaging::Message
  end

  let(:message) do
    instance_double(message_class)
  end

  let(:scopes) do
    Tabulard::Messaging::SCOPES
  end

  it "allows anything by default" do
    expect(validator.validate_code(message)).to be true
    expect(validator.validate_code_data(message)).to be true
    expect(validator.validate_scope(message)).to be true
    expect(validator.validate_scope_data(message)).to be true
  end

  describe "#validate" do
    it "doesn't raise when all validations pass" do
      expect { validator.validate(message) }.not_to raise_error
    end

    context "when some validations fail" do
      before do
        allow(message).to receive(:to_h).and_return({})
      end

      context "code_data and scope" do
        before do
          allow(validator).to receive(:validate_scope).with(message).and_return(false)
          allow(validator).to receive(:validate_code_data).with(message).and_return(false)
        end

        it "raises an error with details" do
          expect { validator.validate(message) }.to raise_error(
            validation_error, /code_data, scope/
          )
        end
      end

      context "code and scope_data" do
        before do
          allow(validator).to receive(:validate_code).with(message).and_return(false)
          allow(validator).to receive(:validate_scope_data).with(message).and_return(false)
        end

        it "raises an error with details" do
          expect { validator.validate(message) }.to raise_error(
            validation_error, /code, scope_data/
          )
        end
      end
    end
  end

  context "when validating a cell message" do
    let(:validator_class) do
      Class.new(described_class) { cell }
    end

    it "validates an exact scope" do
      msg1 = instance_double(message_class, scope: scopes::CELL)
      msg2 = instance_double(message_class, scope: double)
      expect(validator.validate_scope(msg1)).to be true
      expect(validator.validate_scope(msg2)).to be false
    end

    it "validates a subset of scope_data" do
      msg1 = instance_double(message_class, scope_data: { col: "AD", row: 7 })
      msg2 = instance_double(message_class, scope_data: { col: 7, row: "AD" })
      expect(validator.validate_scope_data(msg1)).to be true
      expect(validator.validate_scope_data(msg2)).to be false
    end
  end

  context "when validating a row message" do
    let(:validator_class) do
      Class.new(described_class) { row }
    end

    it "validates an exact scope" do
      msg1 = instance_double(message_class, scope: scopes::ROW)
      msg2 = instance_double(message_class, scope: double)
      expect(validator.validate_scope(msg1)).to be true
      expect(validator.validate_scope(msg2)).to be false
    end

    it "validates a subset of scope_data" do
      msg1 = instance_double(message_class, scope_data: { row: 7 })
      msg2 = instance_double(message_class, scope_data: { row: "AD" })
      expect(validator.validate_scope_data(msg1)).to be true
      expect(validator.validate_scope_data(msg2)).to be false
    end
  end

  context "when validating a col message" do
    let(:validator_class) do
      Class.new(described_class) { col }
    end

    it "validates an exact scope" do
      msg1 = instance_double(message_class, scope: scopes::COL)
      msg2 = instance_double(message_class, scope: double)
      expect(validator.validate_scope(msg1)).to be true
      expect(validator.validate_scope(msg2)).to be false
    end

    it "validates a subset of scope_data" do
      msg1 = instance_double(message_class, scope_data: { col: "AD" })
      msg2 = instance_double(message_class, scope_data: { col: 7 })
      expect(validator.validate_scope_data(msg1)).to be true
      expect(validator.validate_scope_data(msg2)).to be false
    end
  end

  context "when validating a sheet message" do
    let(:validator_class) do
      Class.new(described_class) { sheet }
    end

    it "validates an exact scope" do
      msg1 = instance_double(message_class, scope: scopes::SHEET)
      msg2 = instance_double(message_class, scope: double)
      expect(validator.validate_scope(msg1)).to be true
      expect(validator.validate_scope(msg2)).to be false
    end

    it "validates the absence of scope_data" do
      msg1 = instance_double(message_class, scope_data: nil)
      msg2 = instance_double(message_class, scope_data: double)
      expect(validator.validate_scope_data(msg1)).to be true
      expect(validator.validate_scope_data(msg2)).to be false
    end
  end
end
