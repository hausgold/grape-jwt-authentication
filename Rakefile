# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rails/code_statistics'
require 'pp'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

# Load some railties tasks
load 'rails/tasks/statistics.rake'
load 'rails/tasks/annotations.rake'

# Clear the default statistics directory constant
#
# rubocop:disable Style/MutableConstant because we define it
Object.send(:remove_const, :STATS_DIRECTORIES)
::STATS_DIRECTORIES = []
# rubocop:enable Style/MutableConstant

# Monkey patch the Rails +CodeStatistics+ class to support configurable
# patterns per path. This is reuqired to support top-level only file matches.
class CodeStatistics
  DEFAULT_PATTERN = /^(?!\.).*?\.(rb|js|coffee|rake)$/.freeze

  # Pass the possible +pattern+ argument down to the
  # +calculate_directory_statistics+ method call.
  def calculate_statistics
    Hash[@pairs.map do |pair|
      [pair.first, calculate_directory_statistics(*pair[1..-1])]
    end]
  end

  # Match the pattern against the individual file name and the relative file
  # path. This allows top-level only matches.
  def calculate_directory_statistics(directory, pattern = DEFAULT_PATTERN)
    stats = CodeStatisticsCalculator.new

    Dir.foreach(directory) do |file_name|
      path = "#{directory}/#{file_name}"

      if File.directory?(path) && (/^\./ !~ file_name)
        stats.add(calculate_directory_statistics(path, pattern))
      elsif file_name =~ pattern || path =~ pattern
        stats.add_by_file_path(path)
      end
    end

    stats
  end
end

# Configure all code statistics directories
vendors = [
  [:unshift, 'Top-levels', 'lib'],
  [:unshift, 'Top-levels specs', 'spec/grape']
].reverse

vendors.each do |method, type, dir, pattern|
  ::STATS_DIRECTORIES.send(method, [type, dir, pattern].compact)
  ::CodeStatistics::TEST_TYPES << type if type.include? 'specs'
end

# Setup annotations
ENV['SOURCE_ANNOTATION_DIRECTORIES'] = 'spec,doc'

desc 'Enumerate all annotations'
task :notes do
  SourceAnnotationExtractor.enumerate '@?OPTIMIZE|@?FIXME|@?TODO', tag: true
end
