# frozen_string_literal: true

require_relative "../constants"

module Sheetah
  module Messaging
    module Validations
      module Mixins
        module CellValidations
          def validate_scope(message)
            message.scope == SCOPES::CELL
          end

          def validate_scope_data(message)
            message.scope_data in { col: String, row: Integer }
          end
        end

        module ColValidations
          def validate_scope(message)
            message.scope == SCOPES::COL
          end

          def validate_scope_data(message)
            message.scope_data in { col: String }
          end
        end

        module RowValidations
          def validate_scope(message)
            message.scope == SCOPES::ROW
          end

          def validate_scope_data(message)
            message.scope_data in { row: Integer }
          end
        end

        module SheetValidations
          def validate_scope(message)
            message.scope == SCOPES::SHEET
          end

          def validate_scope_data(message)
            message.scope_data.nil?
          end
        end

        module NilCodeData
          def validate_code_data(message)
            message.code_data.nil?
          end
        end
      end
    end
  end
end
