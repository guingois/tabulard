# frozen_string_literal: true

require "tabulard/table"

RSpec.describe Tabulard::Table, monadic_result: true do
  let(:table_class) do
    c = Class.new do
      def initialize(foo, bar:)
        @foo = foo
        @bar = bar
      end
    end

    c.include(described_class)

    stub_const("TableClass", c)

    c
  end

  let(:table) do
    table_class.new(foo, bar: bar)
  end

  let(:foo) { double }
  let(:bar) { double }

  describe "::Error" do
    subject { table_class::Error }

    it "exposes some kind of Tabulard::Errors::Error" do
      expect(subject.superclass).to be(Tabulard::Errors::Error)
    end
  end

  describe "::ClosureError" do
    subject { table_class::ClosureError }

    it "exposes some kind of Tabulard::Table::Error" do
      expect(subject.superclass).to be(Tabulard::Table::Error)
    end
  end

  describe "::InputError" do
    subject { table_class::InputError }

    it "exposes some kind of Tabulard::Table::Error" do
      expect(subject.superclass).to be(Tabulard::Table::Error)
    end
  end

  describe "::Header" do
    let(:col) { double }
    let(:val) { double }

    let(:wrapper) { table_class::Header.new(col: col, value: val) }

    it "exposes a header wrapper" do
      expect(wrapper).to have_attributes(col: col, value: val)
    end

    it "is comparable" do
      expect(wrapper).to eq(table_class::Header.new(col: col, value: val))
      expect(wrapper).not_to eq(table_class::Header.new(col: double, value: val))
    end
  end

  describe "::Row" do
    let(:row) { double }
    let(:val) { double }

    let(:wrapper) { table_class::Row.new(row: row, value: val) }

    it "exposes a row wrapper" do
      expect(wrapper).to have_attributes(row: row, value: val)
    end

    it "is comparable" do
      expect(wrapper).to eq(table_class::Row.new(row: row, value: val))
      expect(wrapper).not_to eq(table_class::Row.new(row: double, value: val))
    end
  end

  describe "::Cell" do
    let(:row) { double }
    let(:col) { double }
    let(:val) { double }

    let(:wrapper) { table_class::Cell.new(row: row, col: col, value: val) }

    it "exposes a row wrapper" do
      expect(wrapper).to have_attributes(row: row, col: col, value: val)
    end

    it "is comparable" do
      expect(wrapper).to eq(table_class::Cell.new(row: row, col: col, value: val))
      expect(wrapper).not_to eq(table_class::Cell.new(row: double, col: col, value: val))
    end
  end

  describe "singleton class methods" do
    let(:samples) do
      [
        ["A", 1],
        ["B", 2],
        ["Z", 26],
        ["AA", 27],
        ["AZ", 52],
        ["BA", 53],
        ["ZA", 677],
        ["ZZ", 702],
        ["AAA", 703],
        ["AAZ", 728],
        ["ABA", 729],
        ["BZA", 2029],
      ]
    end

    describe "::col2int" do
      it "turns letter-based indexes into integer-based indexes" do
        samples.each do |(col, int)|
          res = described_class.col2int(col)
          expect(res).to eq(int), "Expected #{col} => #{int}, got: #{res}"
        end
      end

      it "fails on invalid inputs" do
        expect { described_class.col2int(nil) }.to raise_error(ArgumentError)
        expect { described_class.col2int("") }.to raise_error(ArgumentError)
        expect { described_class.col2int("a") }.to raise_error(ArgumentError)
        expect { described_class.col2int("€") }.to raise_error(ArgumentError)
      end
    end

    describe "::int2col" do
      it "turns integer-based indexes into letter-based indexes" do
        samples.each do |(col, int)|
          res = described_class.int2col(int)
          expect(res).to eq(col), "Expected #{int} => #{col}, got: #{res}"
        end
      end

      it "fails on invalid inputs" do
        expect { described_class.int2col(nil) }.to raise_error(ArgumentError)
        expect { described_class.int2col(0) }.to raise_error(ArgumentError)
        expect { described_class.int2col(-12) }.to raise_error(ArgumentError)
        expect { described_class.int2col(27.0) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "::open" do
    let(:table) do
      instance_double(table_class)
    end

    before do
      allow(table_class).to receive(:new).with(foo, bar: bar).and_return(table)
    end

    context "without a block" do
      it "returns a new table wrapped as a Success" do
        expect(table_class.open(foo, bar: bar)).to eq(Success(table))
      end
    end

    context "with a block" do
      before do
        allow(table).to receive(:close)
      end

      it "yields a new table" do
        yielded = false

        table_class.open(foo, bar: bar) do |opened_table|
          yielded = true
          expect(opened_table).to be(table)
        end

        expect(yielded).to be(true)
      end

      it "returns the value of the block" do
        block_result = double
        actual_block_result = table_class.open(foo, bar: bar) { block_result }

        expect(actual_block_result).to eq(block_result)
      end

      it "closes after yielding" do
        table_class.open(foo, bar: bar) do
          expect(table).not_to have_received(:close)
        end

        expect(table).to have_received(:close)
      end

      context "when an exception is raised" do
        let(:exception)   { Class.new(StandardError) }
        let(:error)       { Class.new(Tabulard::Table::Error) }
        let(:input_error) { Class.new(Tabulard::Table::InputError) }

        context "without yielding control" do
          it "doesn't rescue an exception" do
            allow(table_class).to receive(:new).and_raise(exception)

            expect do
              table_class.open(foo, bar: bar)
            end.to raise_error(exception)
          end

          it "doesn't rescue an error" do
            allow(table_class).to receive(:new).and_raise(error)

            expect do
              table_class.open(foo, bar: bar)
            end.to raise_error(error)
          end

          it "rescues an input error and returns a failure" do
            allow(table_class).to receive(:new).and_raise(input_error.exception)

            result = table_class.open(foo, bar: bar)

            expect(result).to eq(Failure())
          end
        end

        context "while yielding control" do
          it "doesn't rescue but closes after an exception is raised" do
            expect do
              table_class.open(foo, bar: bar) do
                expect(table).not_to have_received(:close)
                raise exception
              end
            end.to raise_error(exception)

            expect(table).to have_received(:close)
          end

          it "doesn't rescue but closes after an error is raised" do
            expect do
              table_class.open(foo, bar: bar) do
                expect(table).not_to have_received(:close)
                raise error
              end
            end.to raise_error(error)

            expect(table).to have_received(:close)
          end

          it "rescues and closes after an input error is raised" do
            table_class.open(foo, bar: bar) do
              expect(table).not_to have_received(:close)
              raise input_error
            end

            expect(table).to have_received(:close)
          end

          it "rescues and returns an empty failure after an input error is raised" do
            e = input_error.exception # raise the instance directly to simplify result matching

            result = table_class.open(foo, bar: bar) do
              raise e
            end

            expect(result).to eq(Failure())
          end
        end
      end
    end
  end

  describe "#each_header" do
    it "is abstract" do
      expect { table.each_header }.to raise_error(
        NoMethodError, "You must implement TableClass#each_header => self"
      )
    end
  end

  describe "#each_row" do
    it "is abstract" do
      expect { table.each_row }.to raise_error(
        NoMethodError, "You must implement TableClass#each_row => self"
      )
    end
  end

  describe "#close" do
    before { table }

    it "removes the instance variables" do
      expect { table.close }.to [
        change { table.instance_variable_defined?(:@foo) }.from(true).to(false),
        change { table.instance_variable_defined?(:@bar) }.from(true).to(false),
      ].reduce(:&)
    end

    it "marks the instance as closed" do
      expect { table.close }.to change(table, :closed?).from(false).to(true)
    end

    it "returns nil" do
      expect(table.close).to be_nil
    end
  end
end
