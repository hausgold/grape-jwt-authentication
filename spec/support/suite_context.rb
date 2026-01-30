# frozen_string_literal: true

# Print some information
#
# rubocop:disable Rails/Output -- because we want to write to stdout here
# rubocop:disable RSpec/Output -- ditto
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
# rubocop:enable Rails/Output
# rubocop:enable RSpec/Output
