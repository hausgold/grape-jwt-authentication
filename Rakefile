# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'countless/rake_tasks'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

# Configure all code statistics directories
Countless.configure do |config|
  config.stats_base_directories = [
    { name: 'Top-levels',
      pattern: 'lib/**/*.rb' },
    { name: 'Top-levels specs', test: true,
      pattern: 'spec/grape/**/*.rb' }
  ]
end
