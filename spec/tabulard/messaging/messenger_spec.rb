# frozen_string_literal: true

require "tabulard/messaging"

RSpec.describe Tabulard::Messaging::Messenger do
  let(:scopes) { Tabulard::Messaging::SCOPES }
  let(:severities) { Tabulard::Messaging::SEVERITIES }

  let(:row) { double }
  let(:col) { double }

  def be_the_frozen(obj)
    be(obj) & be_frozen
  end

  describe "building methods" do
    let(:scope) { Object.new }
    let(:scope_data) { Object.new }

    describe "#initialize" do
      it "has some default attributes" do
        messenger = described_class.new

        expect(messenger).to have_attributes(
          scope: scopes::TABLE,
          scope_data: nil,
          messages: []
        )
      end

      it "may have some custom, frozen attributes" do
        messenger = described_class.new(scope: scope, scope_data: scope_data)

        expect(messenger).to have_attributes(
          scope: be_the_frozen(scope),
          scope_data: be_the_frozen(scope_data),
          messages: []
        )
      end
    end

    describe "#dup" do
      let(:messenger1) do
        described_class.new(scope: scope, scope_data: scope_data)
      end

      it "returns a new instance" do
        messenger2 = messenger1.dup
        expect(messenger2).to eq(messenger1)
        expect(messenger2).not_to be(messenger1)
      end

      it "preserves some attributes" do
        messenger1.messages << "foobar"

        messenger2 = messenger1.dup
        expect(messenger2.messages).to be_empty
        expect(messenger2.messages).not_to be(messenger1.messages)
      end
    end
  end

  describe "#scoping!" do
    subject do
      ->(&block) { messenger.scoping!(new_scope, new_scope_data, &block) }
    end

    let(:old_scope) { Object.new }
    let(:old_scope_data) { Object.new }

    let(:new_scope) { Object.new }
    let(:new_scope_data) { Object.new }

    let(:messenger) do
      described_class.new(scope: old_scope, scope_data: old_scope_data)
    end

    context "without a block" do
      it "returns the receiver" do
        expect(subject.call).to be(messenger)
      end

      it "scopes the receiver" do
        subject.call

        expect(messenger).to have_attributes(
          scope: be_the_frozen(new_scope),
          scope_data: be_the_frozen(new_scope_data)
        )
      end
    end

    context "with a block" do
      it "returns the block value" do
        foo = double
        expect(subject.call { foo }).to eq(foo)
      end

      it "scopes and yields the receiver" do
        expect { |b| subject.call(&b) }.to yield_with_args(
          be(messenger) & have_attributes(
            scope: be_the_frozen(new_scope),
            scope_data: be_the_frozen(new_scope_data)
          )
        )
      end

      it "unscopes the receiver after the block" do
        subject.call {}

        expect(messenger).to have_attributes(
          scope: be_the_frozen(old_scope),
          scope_data: be_the_frozen(old_scope_data)
        )
      end

      it "unscopes the receiver after the block, even if it raises" do
        e = StandardError.new

        expect { subject.call { raise(e) } }.to raise_error(e)

        expect(messenger).to have_attributes(
          scope: be_the_frozen(old_scope),
          scope_data: be_the_frozen(old_scope_data)
        )
      end
    end
  end

  describe "#scoping! variants" do
    let(:scoping_block) { proc {} }
    let(:scoping_result) { double }

    def allow_method_call_checking_block(receiver, method_name, *args, **opts, &block)
      result = double

      allow(receiver).to receive(method_name) do |*a, **o, &b|
        expect(a).to eq(args)
        expect(o).to eq(opts)
        expect(b).to eq(block)
        result
      end

      result
    end

    def stub_scoping!(receiver, ...)
      allow_method_call_checking_block(receiver, :scoping!, ...)
    end

    describe "#scoping" do
      let(:messenger) { described_class.new }
      let(:messenger_dup) { messenger.dup }

      let(:scope) { double }
      let(:scope_data) { double }

      before do
        allow(messenger).to receive(:dup).and_return(messenger_dup)
      end

      it "applies the correct scoping to a receiver duplicate (with a block)" do
        scoping_result = stub_scoping!(messenger_dup, scope, scope_data, &scoping_block)
        expect(messenger.scoping(scope, scope_data, &scoping_block)).to eq(scoping_result)
      end

      it "applies the correct scoping to a receiver duplicate (without a block)" do
        scoping_result = stub_scoping!(messenger_dup, scope, scope_data)
        expect(messenger.scoping(scope, scope_data)).to eq(scoping_result)
      end
    end

    describe "#scope_row!" do
      context "when the messenger is unscoped" do
        let(:messenger) { described_class.new }

        it "scopes the messenger to the given row (with a block)" do
          scoping_result = stub_scoping!(messenger, scopes::ROW, { row: row }, &scoping_block)
          expect(messenger.scope_row!(row, &scoping_block)).to eq(scoping_result)
        end

        it "scopes the messenger to the given row (without a block)" do
          scoping_result = stub_scoping!(messenger, scopes::ROW, { row: row })
          expect(messenger.scope_row!(row)).to eq(scoping_result)
        end
      end

      context "when the messenger is scoped to another row" do
        let(:other_row) { double }
        let(:messenger) { described_class.new(scope: scopes::ROW, scope_data: { row: other_row }) }

        it "scopes the messenger to the given row (with a block)" do
          scoping_result = stub_scoping!(messenger, scopes::ROW, { row: row }, &scoping_block)
          expect(messenger.scope_row!(row, &scoping_block)).to eq(scoping_result)
        end

        it "scopes the messenger to the given row (without a block)" do
          scoping_result = stub_scoping!(messenger, scopes::ROW, { row: row })
          expect(messenger.scope_row!(row)).to eq(scoping_result)
        end
      end

      context "when the messenger is scoped to a col" do
        let(:messenger) { described_class.new(scope: scopes::COL, scope_data: { col: col }) }

        it "scopes the messenger to the appropriate cell (with a block)" do
          scoping_result =
            stub_scoping!(messenger, scopes::CELL, { col: col, row: row }, &scoping_block)
          expect(messenger.scope_row!(row, &scoping_block)).to eq(scoping_result)
        end

        it "scopes the messenger to the appropriate cell (without a block)" do
          scoping_result = stub_scoping!(messenger, scopes::CELL, { col: col, row: row })
          expect(messenger.scope_row!(row)).to eq(scoping_result)
        end
      end

      context "when the messenger is scoped to a cell" do
        let(:other_row) { double }

        let(:messenger) do
          described_class.new(scope: scopes::CELL, scope_data: { col: col, row: other_row })
        end

        it "scopes the messenger to the new appropriate cell (with a block)" do
          scoping_result =
            stub_scoping!(messenger, scopes::CELL, { col: col, row: row }, &scoping_block)
          expect(messenger.scope_row!(row, &scoping_block)).to eq(scoping_result)
        end

        it "scopes the messenger to the new appropriate cell (without a block)" do
          scoping_result = stub_scoping!(messenger, scopes::CELL, { col: col, row: row })
          expect(messenger.scope_row!(row)).to eq(scoping_result)
        end
      end
    end

    describe "#scope_row" do
      def stub_scope_row!(receiver, ...)
        allow_method_call_checking_block(receiver, :scope_row!, ...)
      end

      let(:messenger) { described_class.new }
      let(:messenger_dup) { messenger.dup }

      before do
        allow(messenger).to receive(:dup).and_return(messenger_dup)
      end

      it "applies the correct scoping to a receiver duplicate (with a block)" do
        scoping_result = stub_scope_row!(messenger_dup, row, &scoping_block)
        expect(messenger.scope_row(row, &scoping_block)).to eq(scoping_result)
      end

      it "applies the correct scoping to a receiver duplicate (without a block)" do
        scoping_result = stub_scope_row!(messenger_dup, row)
        expect(messenger.scope_row(row)).to eq(scoping_result)
      end
    end

    describe "#scope_col!" do
      context "when the messenger is unscoped" do
        let(:messenger) { described_class.new }

        it "scopes the messenger to the given col (with a block)" do
          scoping_result = stub_scoping!(messenger, scopes::COL, { col: col }, &scoping_block)
          expect(messenger.scope_col!(col, &scoping_block)).to eq(scoping_result)
        end

        it "scopes the messenger to the given col (without a block)" do
          scoping_result = stub_scoping!(messenger, scopes::COL, { col: col })
          expect(messenger.scope_col!(col)).to eq(scoping_result)
        end
      end

      context "when the messenger is scoped to another col" do
        let(:other_col) { double }
        let(:messenger) { described_class.new(scope: scopes::COL, scope_data: { col: other_col }) }

        it "scopes the messenger to the given col (with a block)" do
          scoping_result = stub_scoping!(messenger, scopes::COL, { col: col }, &scoping_block)
          expect(messenger.scope_col!(col, &scoping_block)).to eq(scoping_result)
        end

        it "scopes the messenger to the given col (without a block)" do
          scoping_result = stub_scoping!(messenger, scopes::COL, { col: col })
          expect(messenger.scope_col!(col)).to eq(scoping_result)
        end
      end

      context "when the messenger is scoped to a row" do
        let(:messenger) { described_class.new(scope: scopes::ROW, scope_data: { row: row }) }

        it "scopes the messenger to the appropriate cell (with a block)" do
          scoping_result =
            stub_scoping!(messenger, scopes::CELL, { row: row, col: col }, &scoping_block)
          expect(messenger.scope_col!(col, &scoping_block)).to eq(scoping_result)
        end

        it "scopes the messenger to the appropriate cell (without a block)" do
          scoping_result = stub_scoping!(messenger, scopes::CELL, { row: row, col: col })
          expect(messenger.scope_col!(col)).to eq(scoping_result)
        end
      end

      context "when the messenger is scoped to a cell" do
        let(:other_col) { double }

        let(:messenger) do
          described_class.new(scope: scopes::CELL, scope_data: { row: row, col: other_col })
        end

        it "scopes the messenger to the new appropriate cell (with a block)" do
          scoping_result =
            stub_scoping!(messenger, scopes::CELL, { row: row, col: col }, &scoping_block)
          expect(messenger.scope_col!(col, &scoping_block)).to eq(scoping_result)
        end

        it "scopes the messenger to the new appropriate cell (without a block)" do
          scoping_result = stub_scoping!(messenger, scopes::CELL, { row: row, col: col })
          expect(messenger.scope_col!(col)).to eq(scoping_result)
        end
      end
    end

    describe "#scope_col" do
      def stub_scope_col!(receiver, ...)
        allow_method_call_checking_block(receiver, :scope_col!, ...)
      end

      let(:messenger) { described_class.new }
      let(:messenger_dup) { messenger.dup }

      before do
        allow(messenger).to receive(:dup).and_return(messenger_dup)
      end

      it "applies the correct scoping to a receiver duplicate (with a block)" do
        scoping_result = stub_scope_col!(messenger_dup, col, &scoping_block)
        expect(messenger.scope_col(col, &scoping_block)).to eq(scoping_result)
      end

      it "applies the correct scoping to a receiver duplicate (without a block)" do
        scoping_result = stub_scope_col!(messenger_dup, col)
        expect(messenger.scope_col(col)).to eq(scoping_result)
      end
    end
  end

  describe "adding messages" do
    let(:scope) { Object.new }
    let(:scope_data) { Object.new }

    let(:code) { double }
    let(:code_data) { double }

    let(:message) do
      Tabulard::Messaging::Message.new(code: code, code_data: code_data)
    end

    let(:messenger) { described_class.new(scope: scope, scope_data: scope_data) }

    describe "#warn" do
      it "returns the receiver" do
        expect(messenger.warn(message)).to be(messenger)
      end

      it "adds the code & code_data as a warning" do
        messenger.warn(message)

        expect(messenger.messages).to contain_exactly(
          Tabulard::Messaging::Message.new(
            code: code,
            code_data: code_data,
            scope: scope,
            scope_data: scope_data,
            severity: severities::WARN
          )
        )
      end
    end

    describe "#error" do
      it "returns the receiver" do
        expect(messenger.error(message)).to be(messenger)
      end

      it "adds the code & code_data as an error" do
        messenger.error(message)

        expect(messenger.messages).to contain_exactly(
          Tabulard::Messaging::Message.new(
            code: code,
            code_data: code_data,
            scope: scope,
            scope_data: scope_data,
            severity: severities::ERROR
          )
        )
      end
    end
  end

  describe "validating messages" do
    let(:message) do
      Tabulard::Messaging::Message.new(code: double)
    end

    it "implicitly depends on a global config" do
      config = instance_double(Tabulard::Messaging::Config, validate_messages: double)
      allow(Tabulard::Messaging).to receive(:config).and_return(config)
      messenger = described_class.new
      expect(messenger.validate_messages).to eq(config.validate_messages)
    end

    it "is passed to a duplicate" do
      messenger = described_class.new(validate_messages: val = double)
      expect(messenger.dup.validate_messages).to eq(val)
    end

    context "when enabled" do
      let(:messenger) do
        described_class.new(validate_messages: true)
      end

      it "validates a message while adding it" do
        expect(message).to receive(:validate).with(no_args)
        messenger.warn(message)
      end
    end

    context "when disabled" do
      let(:messenger) do
        described_class.new(validate_messages: false)
      end

      it "validates a message while adding it" do
        expect(message).not_to receive(:validate)
        messenger.warn(message)
      end
    end
  end
end
