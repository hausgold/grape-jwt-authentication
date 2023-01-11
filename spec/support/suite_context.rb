# frozen_string_literal: true

# Print some information
puts
puts <<DESC
  -------------- Versions --------------
            Ruby: #{"#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"}
  Active Support: #{ActiveSupport.version}
  --------------------------------------
DESC
puts
