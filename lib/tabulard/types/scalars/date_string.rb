# frozen_string_literal: true

require_relative "scalar"
require_relative "date_string_cast"

module Tabulard
  module Types
    module Scalars
      DateString = Scalar.cast(DateStringCast)
    end
  end
end
