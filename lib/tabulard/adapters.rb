# frozen_string_literal: true

module Tabulard
  module Adapters
    class << self
      def open(*args, adapter:, **opts, &block)
        adapter.open(*args, **opts, &block)
      end
    end
  end
end
