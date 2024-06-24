# frozen_string_literal: true

require "sheetah/backends/xlsx"
require "support/shared/sheet/factories"
require "support/shared/sheet/backend_empty"
require "support/shared/sheet/backend_filled"

RSpec.describe Sheetah::Backends::Xlsx do
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
    fixture_path(source)
  end

  after do |example|
    sheet.close unless example.metadata[:autoclose_sheet] == false
  end

  context "when the input table is empty" do
    let(:source) do
      "xlsx/empty.xlsx"
    end

    let(:source_data) do
      []
    end

    include_examples "sheet/backend_empty", pending_custom_headers: true
  end

  context "when the input table is filled" do
    let(:source) do
      "xlsx/regular.xlsx"
    end

    let(:source_data) do
      [
        ["matricule", "nom", "prénom", "date de naissance", "email"],
        ["004774", "Ytärd", "Glœuiçe", "28/04/1998", "foo@bar.com"],
        [664_623, "Goulijambon", "Carasmine", Date.new(1976, 1, 20), "foo@bar.com"],
      ]
    end

    include_examples "sheet/backend_filled", pending_custom_headers: true
  end

  context "when the input table includes empty rows around the content" do
    let(:source) do
      "xlsx/empty_rows_around.xlsx"
    end

    let(:source_data) do
      [
        ["matricule", "nom", "prénom", "date de naissance", "email"],
        ["004774", "Ytärd", "Glœuiçe", "28/04/1998", "foo@bar.com"],
        [664_623, "Goulijambon", "Carasmine", Date.new(1976, 1, 20), "foo@bar.com"],
      ]
    end

    it "ignores the empty initial rows when detecting the headers" do
      headers = build_headers(source_data[0])
      expect { |b| sheet.each_header(&b) }.to yield_successive_args(*headers)
    end

    it "ignores the empty final rows when detecting the rows" do
      rows = build_rows(source_data[1..], row: 3)
      expect { |b| sheet.each_row(&b) }.to yield_successive_args(*rows)
    end
  end

  context "when the input table includes empty rows within the content" do
    let(:source) do
      "xlsx/empty_rows_within.xlsx"
    end

    let(:source_data) do
      empty_row = Array.new(5)

      [
        ["matricule", "nom", "prénom", "date de naissance", "email"],
        empty_row,
        ["004774", "Ytärd", "Glœuiçe", "28/04/1998", "foo@bar.com"],
        empty_row,
        [664_623, "Goulijambon", "Carasmine", Date.new(1976, 1, 20), "foo@bar.com"],
      ]
    end

    it "ignores them when detecting the headers" do
      headers = build_headers(source_data[0])
      expect { |b| sheet.each_header(&b) }.to yield_successive_args(*headers)
    end

    it "doesn't ignore them when detecting the rows" do
      rows = build_rows(source_data[1..])
      expect { |b| sheet.each_row(&b) }.to yield_successive_args(*rows)
    end
  end

  context "when the input table includes empty columns before the content" do
    let(:source) do
      "xlsx/empty_cols_before.xlsx"
    end

    let(:source_data) do
      [
        ["matricule", "nom", "prénom", "date de naissance", "email"],
        ["004774", "Ytärd", "Glœuiçe", "28/04/1998", "foo@bar.com"],
        [664_623, "Goulijambon", "Carasmine", Date.new(1976, 1, 20), "foo@bar.com"],
      ]
    end

    it "ignores the initial empty columns when detecting the headers" do
      headers = build_headers(source_data[0], col: "B")
      expect { |b| sheet.each_header(&b) }.to yield_successive_args(*headers)
    end

    it "ignores the initial empty columns when detecting the rows" do
      rows = build_rows(source_data[1..], col: "B")
      expect { |b| sheet.each_row(&b) }.to yield_successive_args(*rows)
    end
  end
end
