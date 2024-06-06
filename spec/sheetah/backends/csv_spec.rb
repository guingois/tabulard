# frozen_string_literal: true

require "sheetah/backends/csv"
require "support/shared/sheet/factories"
require "support/shared/sheet/backend_empty"
require "support/shared/sheet/backend_filled"
require "csv"
require "stringio"

RSpec.describe Sheetah::Backends::Csv do
  include_context "sheet/factories"

  let(:input) do
    stub_input(source)
  end

  let(:sheet_opts) do
    {}
  end

  let(:sheet) do
    described_class.new(input, **sheet_opts)
  end

  def stub_input(source)
    csv = CSV.generate do |csv_io|
      source.each do |row|
        csv_io << row
      end
    end

    StringIO.new(csv, "r:UTF-8")
  end

  after do |example|
    sheet.close unless example.metadata[:autoclose_sheet] == false
    input.close
  end

  context "when the input table is empty" do
    let(:source) do
      []
    end

    include_examples "sheet/backend_empty"
  end

  context "when the input table is filled" do
    let(:source) do
      Array.new(4) do |row|
        Array.new(4) do |col|
          "(#{row},#{col})"
        end.freeze
      end.freeze
    end

    include_examples "sheet/backend_filled"
  end

  describe "encodings" do
    let(:utf8_path) { fixture_path("csv/utf8.csv") }
    let(:latin9_path) { fixture_path("csv/latin9.csv") }

    let(:headers_data_utf8) do
      [
        "Matricule",
        "Nom",
        "Prénom",
        "Email",
        "Date de naissance",
        "Entrée en entreprise",
        "Administrateur",
        "Bio",
        "Service",
      ]
    end

    let(:headers_data_latin9) do
      headers_data_utf8.map { |str| str.encode(Encoding::ISO_8859_15) }
    end

    let(:sheet_headers_data) { sheet.each_header.map(&:value) }

    context "when the IO is opened with the correct external encoding" do
      let(:input) do
        File.new(latin9_path, external_encoding: Encoding::ISO_8859_15)
      end

      it "does not interfere" do
        expect(sheet_headers_data).to eq(headers_data_latin9)
      end
    end

    context "when the IO is opened with an incorrect external encoding" do
      let(:input) do
        File.new(latin9_path, external_encoding: Encoding::UTF_8)
      end

      it "fails" do
        expect { sheet }.to raise_error(described_class::InputError)
      end
    end

    context "when the (correct) external encoding differs from the internal one" do
      let(:input) do
        File.new(
          latin9_path,
          external_encoding: Encoding::ISO_8859_15,
          internal_encoding: Encoding::UTF_8
        )
      end

      it "does not interfere" do
        expect(sheet_headers_data).to eq(headers_data_utf8)
      end
    end
  end

  describe "CSV options" do
    let(:source) { [] }

    it "requires a specific col_sep and quote_char, and an automatic row_sep" do
      expect(CSV).to receive(:new)
        .with(input, row_sep: :auto, col_sep: ",", quote_char: '"')
        .and_call_original

      sheet
    end
  end

  describe "#close" do
    let(:source) { [] }

    it "doesn't close the underlying sheet" do
      expect { sheet.close }.not_to change(input, :closed?).from(false)
    end
  end
end
