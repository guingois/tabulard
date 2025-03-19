# frozen_string_literal: true

require "tabulard/utils/monadic_result"

RSpec.configure do |config|
  config.include(Tabulard::Utils::MonadicResult, monadic_result: true)
end
