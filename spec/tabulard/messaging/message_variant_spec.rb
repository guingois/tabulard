# frozen_string_literal: true

require "tabulard/messaging/message_variant"

RSpec.describe Tabulard::Messaging::MessageVariant do
  let(:code) { double }

  describe "::code" do
    context "when a CODE constant is not defined" do
      it "fails with an exception" do
        expect { described_class.code }.to raise_error(NameError, /CODE/)
      end
    end

    context "when a CODE constant is defined" do
      before do
        stub_const("#{described_class}::CODE", code)
      end

      it "exposes the constant" do
        expect(described_class.code).to eq(code)
      end

      context "when called from a subclass" do
        let(:subclass) { Class.new(described_class) }

        before do
          stub_const("#{described_class}Foo", subclass)
        end

        it "exposes the constant from the parent class" do
          expect(subclass.code).to eq(code)
        end

        context "when the subclass also defines the constant" do
          let(:subclass_code) { double }

          before do
            stub_const("#{described_class}Foo::CODE", subclass_code)
          end

          it "exposes the constant from the subclass" do
            expect(subclass.code).to eq(subclass_code)
          end
        end
      end
    end
  end

  describe "::new" do
    before do
      allow(described_class).to receive(:code).and_return(code)
    end

    it "assigns that code to instances automatically" do
      message = described_class.new
      expect(message.code).to eq(code)
    end
  end

  describe "validations" do
    let(:validator) { described_class.validator }

    before do
      allow(described_class).to receive(:code).and_return(code)
    end

    it "validates that the message code is that same as the class code" do
      message1 = described_class.new
      message2 = described_class.new(code: double)
      expect(validator.validate_code(message1)).to be true
      expect(validator.validate_code(message2)).to be false
    end
  end
end
