# frozen_string_literal: true

require "csv"

require_relative "../table"

module Tabulard
  module Backends
    class Csv
      include Table

      class InvalidCSV < Message
        CODE = "invalid_csv"

        def_validator do
          table
          nil_code_data
        end
      end

      DEFAULTS = {
        row_sep: :auto,
        col_sep: ",",
        quote_char: '"',
      }.freeze

      private_constant :DEFAULTS

      def self.defaults
        DEFAULTS
      end

      def initialize(
        io,
        row_sep: self.class.defaults[:row_sep],
        col_sep: self.class.defaults[:col_sep],
        quote_char: self.class.defaults[:quote_char],
        headers: nil,
        **opts
      )
        super(**opts)

        csv = CSV.new(
          io,
          row_sep: row_sep,
          col_sep: col_sep,
          quote_char: quote_char
        )

        if headers
          init_with_headers(csv, headers)
        else
          init_without_headers(csv)
        end
      end

      def each_header
        raise_if_closed

        return to_enum(:each_header) { @cols_count } unless block_given?
        return self if @cols_count.zero?

        @headers.each_with_index do |header, col_idx|
          col = Table.int2col(col_idx + 1)

          yield Header.new(col: col, value: header)
        end

        self
      end

      def each_row
        raise_if_closed

        return to_enum(:each_row) unless block_given?
        return self unless @csv

        handle_malformed_csv do
          @csv.each.with_index(@first_row_name) do |raw, row|
            value = Array.new(@cols_count) do |col_idx|
              col = Table.int2col(col_idx + 1)

              Cell.new(row: row, col: col, value: raw[col_idx])
            end

            yield Row.new(row: row, value: value)
          end
        end

        self
      end

      # The backend isn't responsible for opening the IO, and therefore it is not responsible for
      # closing it either.

      private

      def handle_malformed_csv
        yield
      rescue CSV::MalformedCSVError
        messenger.error(InvalidCSV.new)

        raise InputError
      end

      def init_with_headers(csv, headers_data)
        first_row_data = handle_malformed_csv { csv.shift }

        if first_row_data
          ensure_compatible_size(first_row_data.size, headers_data.size)

          csv.rewind
          @csv = csv
          @first_row_name = 1
        else
          @csv = nil
        end

        @headers = headers_data
        @cols_count = @headers.size
      end

      def init_without_headers(csv)
        first_row_data = handle_malformed_csv { csv.shift }

        if first_row_data
          @csv = csv
          @first_row_name = 2
          @headers = first_row_data
          @cols_count = @headers.size
        else
          @csv = nil
          @headers = nil
          @cols_count = 0
        end
      end
    end
  end
end
