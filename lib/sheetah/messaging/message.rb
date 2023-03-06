# frozen_string_literal: true

require_relative "constants"

module Sheetah
  module Messaging
    class Message
      def self.code
        self::CODE if defined?(self::CODE)
      end

      def self.new(**opts)
        code ? super(code: code, **opts) : super
      end

      def initialize(
        code:,
        code_data: nil,
        scope: SCOPES::SHEET,
        scope_data: nil,
        severity: SEVERITIES::WARN
      )
        @code        = code
        @code_data   = code_data
        @scope       = scope
        @scope_data  = scope_data
        @severity    = severity
      end

      attr_accessor(
        :code,
        :code_data,
        :scope,
        :scope_data,
        :severity
      )

      def ==(other)
        other.is_a?(self.class) &&
          code       == other.code &&
          code_data  == other.code_data &&
          scope      == other.scope &&
          scope_data == other.scope_data &&
          severity   == other.severity
      end

      def to_s
        parts = [scoping_to_s, "#{severity}: #{code}", code_data]
        parts.compact!
        parts.join(" ")
      end

      def to_h
        {
          code: code,
          code_data: code_data,
          scope: scope,
          scope_data: scope_data,
          severity: severity,
        }
      end

      private

      def scoping_to_s
        case scope
        when SCOPES::SHEET then "[#{scope}]"
        when SCOPES::ROW   then "[#{scope}: #{scope_data[:row]}]"
        when SCOPES::COL   then "[#{scope}: #{scope_data[:col]}]"
        when SCOPES::CELL  then "[#{scope}: #{scope_data[:col]}#{scope_data[:row]}]"
        end
      end
    end
  end
end
