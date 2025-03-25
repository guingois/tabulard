# frozen_string_literal: true

require_relative "constants"

module Tabulard
  module Messaging
    class Messenger
      def initialize(
        scope: SCOPES::TABLE,
        scope_data: nil,
        validate_messages: Messaging.config.validate_messages
      )
        @scope = scope.freeze
        @scope_data = scope_data.freeze
        @messages = []
        @validate_messages = validate_messages
      end

      attr_reader :scope, :scope_data, :messages, :validate_messages

      def ==(other)
        other.is_a?(self.class) &&
          scope == other.scope &&
          scope_data == other.scope_data &&
          messages == other.messages &&
          validate_messages == other.validate_messages
      end

      def dup
        self.class.new(
          scope: @scope,
          scope_data: @scope_data,
          validate_messages: @validate_messages
        )
      end

      def scoping!(scope, scope_data, &block)
        scope      = scope.freeze
        scope_data = scope_data.freeze

        if block
          replace_scoping_block(scope, scope_data, &block)
        else
          replace_scoping_noblock(scope, scope_data)
        end
      end

      def scoping(...)
        dup.scoping!(...)
      end

      def scope_row!(row, &)
        scope = case @scope
                when SCOPES::COL, SCOPES::CELL
                  SCOPES::CELL
                else
                  SCOPES::ROW
                end

        scope_data = @scope_data.dup || {}
        scope_data[:row] = row

        scoping!(scope, scope_data, &)
      end

      def scope_col!(col, &)
        scope = case @scope
                when SCOPES::ROW, SCOPES::CELL
                  SCOPES::CELL
                else
                  SCOPES::COL
                end

        scope_data = @scope_data.dup || {}
        scope_data[:col] = col

        scoping!(scope, scope_data, &)
      end

      def scope_row(...)
        dup.scope_row!(...)
      end

      def scope_col(...)
        dup.scope_col!(...)
      end

      def warn(message)
        add(message, severity: SEVERITIES::WARN)
      end

      def error(message)
        add(message, severity: SEVERITIES::ERROR)
      end

      private

      def add(message, severity:)
        message.scope = @scope
        message.scope_data = @scope_data
        message.severity = severity

        message.validate if @validate_messages

        messages << message

        self
      end

      def replace_scoping_noblock(new_scope, new_scope_data)
        @scope      = new_scope
        @scope_data = new_scope_data

        self
      end

      def replace_scoping_block(new_scope, new_scope_data)
        prev_scope      = @scope
        prev_scope_data = @scope_data

        @scope      = new_scope
        @scope_data = new_scope_data

        begin
          yield self
        ensure
          @scope = prev_scope
          @scope_data = prev_scope_data
        end
      end
    end
  end
end
