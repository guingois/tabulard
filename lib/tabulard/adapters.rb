# frozen_string_literal: true

module Tabulard
  module Adapters
    class << self
      def open(*, adapter:, **, &)
        adapter.open(*, **, &)
      end
    end
  end
end
