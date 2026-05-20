# frozen_string_literal: true

# Print some information
#
# rubocop:disable RSpec/Output -- because we want to write to stdout here
puts
puts <<DESC
  -------------- Versions --------------
            Ruby: #{"#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"}
  Active Support: #{ActiveSupport.version}
           Grape: #{Gem.loaded_specs['grape'].version}
            Rack: #{Gem.loaded_specs['rack'].version}
  --------------------------------------
DESC
puts
# rubocop:enable RSpec/Output
