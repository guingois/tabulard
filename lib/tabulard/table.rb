# frozen_string_literal: true

require_relative "table/col_converter"
require_relative "errors/error"
require_relative "messaging"
require_relative "utils/monadic_result"

module Tabulard
  module Table
    def self.included(mod)
      mod.extend(ClassMethods)
    end

    def self.col2int(...)
      COL_CONVERTER.col2int(...)
    end

    def self.int2col(...)
      COL_CONVERTER.int2col(...)
    end

    module ClassMethods
      def open(*, **)
        table = new(*, **)
        return Utils::MonadicResult::Success.new(table) unless block_given?

        begin
          yield table
        ensure
          table.close
        end
      rescue InputError
        Utils::MonadicResult::Failure.new
      end
    end

    class Error < Errors::Error
    end

    class ClosureError < Error
    end

    class TooFewHeaders < Error
    end

    class TooManyHeaders < Error
    end

    class InputError < Error
    end

    Message = Messaging::MessageVariant

    class Header
      def initialize(col:, value:)
        @col = col
        @value = value
      end

      attr_reader :col, :value

      def ==(other)
        other.is_a?(self.class) && col == other.col && value == other.value
      end

      def row_value_index
        Table.col2int(col) - 1
      end
    end

    class Row
      def initialize(row:, value:)
        @row = row
        @value = value
      end

      attr_reader :row, :value

      def ==(other)
        other.is_a?(self.class) && row == other.row && value == other.value
      end
    end

    class Cell
      def initialize(row:, col:, value:)
        @row = row
        @col = col
        @value = value
      end

      attr_reader :row, :col, :value

      def ==(other)
        other.is_a?(self.class) && row == other.row && col == other.col && value == other.value
      end
    end

    def initialize(messenger: Messaging::Messenger.new)
      @messenger = messenger
      @closed = false
    end

    attr_reader :messenger

    def each_header
      raise NoMethodError, "You must implement #{self.class}#each_header => self"
    end

    def each_row
      raise NoMethodError, "You must implement #{self.class}#each_row => self"
    end

    def close
      return if closed?

      yield if block_given?

      instance_variables.each { |ivar| remove_instance_variable(ivar) }

      @closed = true

      nil
    end

    def closed?
      @closed == true
    end

    private

    def raise_if_closed
      raise ClosureError if closed?
    end

    def ensure_compatible_size(row_size, headers_size)
      case row_size <=> headers_size
      when -1
        raise TooManyHeaders, "Expected #{row_size} headers, got: #{headers_size}"
      when 1
        raise TooFewHeaders, "Expected #{row_size} headers, got: #{headers_size}"
      end
    end
  end
end
