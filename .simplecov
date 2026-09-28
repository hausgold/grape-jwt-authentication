# frozen_string_literal: true

# Fail the run on any deprecated SimpleCov spelling instead of just
# warning, so an old configuration cannot creep back in unnoticed.
SimpleCov.deprecations :raise

# Shared SimpleCov configuration only, the coverage tracking itself is
# started from the spec helper.
SimpleCov.formats :html
