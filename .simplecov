# frozen_string_literal: true

require 'simplecov-html'
require 'simplecov_json_formatter'

SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::JSONFormatter
  ]
)

SimpleCov.start 'test_frameworks' do
  add_filter '/vendor/bundle/'
end
