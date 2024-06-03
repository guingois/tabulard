# frozen_string_literal: true

formatters = []

if ENV["TABULARD_COVERAGE_REPORT_HTML"] == "true"
  formatters << :html
end

if ENV["TABULARD_COVERAGE_REPORT_COBERTURA"] == "true"
  formatters << :cobertura
end

return if formatters.empty?

require "simplecov"

formatters.map! do |formatter|
  case formatter
  when :html
    SimpleCov::Formatter::HTMLFormatter
  when :cobertura
    require "simplecov-cobertura"
    SimpleCov::Formatter::CoberturaFormatter
  end
end

SimpleCov.formatters = formatters

SimpleCov.start do
  coverage_dir "docs/coverage"

  enable_coverage :branch
end
