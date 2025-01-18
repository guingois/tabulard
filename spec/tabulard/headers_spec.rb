# frozen_string_literal: true

require "tabulard/headers"
require "tabulard/column"
require "tabulard/messaging"
require "tabulard/sheet"
require "tabulard/specification"

RSpec.describe Tabulard::Headers, monadic_result: true do
  let(:specification) do
    instance_double(
      Tabulard::Specification,
      required_columns: [],
      ignore_unspecified_columns?: false
    )
  end

  let(:columns) do
    Array.new(10) do
      instance_double(Tabulard::Column)
    end
  end

  let(:messenger) do
    Tabulard::Messaging::Messenger.new
  end

  let(:sheet_headers) do
    Array.new(5) do |i|
      instance_double(Tabulard::Sheet::Header, col: "FOO", value: "header#{i}")
    end
  end

  let(:headers) do
    described_class.new(specification: specification, messenger: messenger)
  end

  def stub_specification(column_by_header)
    column_by_header = column_by_header.transform_keys(&:value)

    allow(specification).to receive(:get) do |header_value|
      column_by_header[header_value]
    end
  end

  before do
    stub_specification(
      sheet_headers[0] => columns[4],
      sheet_headers[1] => columns[1],
      sheet_headers[2] => columns[7],
      sheet_headers[3] => columns[1]
    )
  end

  describe "#result" do
    context "without any #add" do
      it "is a success with no items" do
        expect(headers.result).to eq(Success([]))
      end
    end

    context "with some successful #add" do
      before do
        headers.add(sheet_headers[1])
        headers.add(sheet_headers[2])
        headers.add(sheet_headers[0])
      end

      it "is a success and preserve #add order" do
        expect(headers.result).to eq(
          Success(
            [
              Tabulard::Headers::Header.new(sheet_headers[1], columns[1]),
              Tabulard::Headers::Header.new(sheet_headers[2], columns[7]),
              Tabulard::Headers::Header.new(sheet_headers[0], columns[4]),
            ]
          )
        )
      end

      it "doesn't message" do
        expect(messenger.messages).to be_empty
      end
    end

    context "when a header doesn't match a column" do
      before do
        headers.add(sheet_headers[0])
        headers.add(sheet_headers[4])
      end

      it "is a failure" do
        expect(headers.result).to eq(Failure())
      end

      it "messages the error" do
        expect(messenger.messages).to contain_exactly(
          be_a(Tabulard::Messaging::Message) & have_attributes(
            severity: "ERROR",
            code: "invalid_header",
            code_data: { value: sheet_headers[4].value },
            scope: "COL",
            scope_data: { col: sheet_headers[4].col }
          )
        )
      end
    end

    context "when there is a duplicate" do
      before do
        headers.add(sheet_headers[0])
        headers.add(sheet_headers[3])
        headers.add(sheet_headers[1])
      end

      it "is a failure" do
        expect(headers.result).to eq(Failure())
      end

      it "considers the underlying column, not the header" do
        expect(messenger.messages).to contain_exactly(
          be_a(Tabulard::Messaging::Message) & have_attributes(
            severity: "ERROR",
            code: "duplicated_header",
            code_data: { value: sheet_headers[1].value },
            scope: "COL",
            scope_data: { col: sheet_headers[1].col }
          )
        )
      end
    end
  end
end
