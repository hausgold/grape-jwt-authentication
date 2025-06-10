# frozen_string_literal: true

# Print some information
#
# rubocop:disable Rails/Output -- because we want to write to stdout here
puts
puts <<DESC
  -------------- Versions --------------
            Ruby: #{"#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"}
  Active Support: #{ActiveSupport.version}
  --------------------------------------
DESC
puts
# rubocop:enable Rails/Output
