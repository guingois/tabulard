# frozen_string_literal: true

require_relative "mixins"

module Tabulard
  module Messaging
    module Validations
      module DSL
        def cell
          include Mixins::CellValidations
        end

        def col
          include Mixins::ColValidations
        end

        def row
          include Mixins::RowValidations
        end

        def table
          include Mixins::TableValidations
        end

        def nil_code_data
          include Mixins::NilCodeData
        end
      end
    end
  end
end
