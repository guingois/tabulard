# frozen_string_literal: true

require "tabulard/table_processor"
require "tabulard/specification"

RSpec.describe Tabulard::TableProcessor, monadic_result: true do
  let(:specification) do
    instance_double(Tabulard::Specification)
  end

  let(:processor) do
    described_class.new(specification)
  end

  let(:messenger) do
    instance_double(Tabulard::Messaging::Messenger, messages: double)
  end

  let(:table_class) do
    Class.new { include Tabulard::Table }
  end

  let(:backend_args) do
    [double, double]
  end

  let(:backend_opts) do
    { foo: double, bar: double }
  end

  let(:table) do
    instance_double(table_class)
  end

  def call(&block)
    block ||= proc {} # stub a dummy proc
    processor.call(*backend_args, backend: table_class, **backend_opts, &block)
  end

  def stub_table_open
    stub = receive(:open).with(*backend_args, **backend_opts, messenger: messenger)
    stub = yield(stub) if block_given?
    allow(table_class).to(stub)
  end

  def stub_table_open_ok
    stub_table_open { _1.and_yield(table) }
  end

  def stub_table_open_ko
    stub_table_open { _1.and_return(Failure()) }
  end

  before do
    allow(Tabulard::Messaging::Messenger).to receive(:new).with(no_args).and_return(messenger)
  end

  it "passes the args and opts to Backends.open" do
    actual_args = backend_args
    actual_opts = backend_opts.merge(backend: table_class, messenger: messenger)

    expect(Tabulard::Backends).to(
      receive(:open)
      .with(*actual_args, **actual_opts)
      .and_return(Success())
    )

    processor.call(*actual_args, **actual_opts)
  end

  context "when opening the table fails" do
    before do
      stub_table_open_ko
    end

    it "is an empty failure, with messages" do
      expect(call).to eq(
        Tabulard::TableProcessorResult.new(
          result: Failure(),
          messages: messenger.messages
        )
      )
    end
  end

  shared_context "when there is no table error" do
    let(:table_headers) do
      Array.new(2) { instance_double(Tabulard::Table::Header) }
    end

    let(:table_rows) do
      Array.new(3) { instance_double(Tabulard::Table::Row) }
    end

    let(:messenger) do
      instance_double(Tabulard::Messaging::Messenger, messages: double)
    end

    let(:headers) do
      instance_double(Tabulard::Headers)
    end

    def stub_enumeration(obj, method_name, enumerable)
      enum = Enumerator.new do |yielder|
        enumerable.each { |item| yielder << item }
        obj
      end

      allow(obj).to receive(method_name).with(no_args) do |&block|
        enum.each(&block)
      end
    end

    def stub_headers
      allow(Tabulard::Headers).to(
        receive(:new)
        .with(specification: specification, messenger: messenger)
        .and_return(headers)
      )
    end

    def stub_headers_ops(result)
      table_headers.each do |table_header|
        expect(headers).to receive(:add).with(table_header).ordered
      end

      expect(headers).to receive(:result).and_return(result).ordered
    end

    before do
      stub_headers

      stub_table_open_ok

      stub_enumeration(table, :each_header, table_headers)
      stub_enumeration(table, :each_row, table_rows)
    end
  end

  context "when there is a header error" do
    include_context "when there is no table error"

    before do
      stub_headers_ops(Failure())
    end

    it "is an empty failure, with messages" do
      result = call

      expect(result).to eq(
        Tabulard::TableProcessorResult.new(
          result: Failure(),
          messages: messenger.messages
        )
      )
    end
  end

  context "when there is no error" do
    include_context "when there is no table error"

    let(:headers_spec) do
      double
    end

    let(:processed_rows) do
      Array.new(table_rows.size) { double }
    end

    def stub_row_processing
      allow(Tabulard::RowProcessor).to(
        receive(:new)
        .with(headers: headers_spec, messenger: messenger)
        .and_return(row_processor = instance_double(Tabulard::RowProcessor))
      )

      table_rows.zip(processed_rows) do |row, processed_row|
        allow(row_processor).to receive(:call).with(row).and_return(processed_row)
      end
    end

    before do
      stub_headers_ops(Success(headers_spec))

      stub_row_processing
    end

    it "is an empty success, with messages" do
      result = call

      expect(result).to eq(
        Tabulard::TableProcessorResult.new(
          result: Success(),
          messages: messenger.messages
        )
      )
    end

    it "yields each processed row" do
      expect { |b| call(&b) }.to yield_successive_args(*processed_rows)
    end
  end
end
