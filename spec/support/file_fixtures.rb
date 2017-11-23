# frozen_string_literal: true

# Emulate the rspec-rails file_fixture method to easily load file fixtures
# within tests.
#
# @param file [String] The name of the file fixture
# @return [File]
def file_fixture(file)
  File.new(File.join(__dir__, '..', 'fixtures', 'files', file))
end
