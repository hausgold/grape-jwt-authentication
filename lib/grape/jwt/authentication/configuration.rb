# frozen_string_literal: true

module Grape
  module Jwt
    module Authentication
      # The configuration for the Grape JWT authentication concern.
      class Configuration
        include ActiveSupport::Configurable

        config_accessor(:rsa_public_key_url) { nil }
        config_accessor(:cache_rsa_public_key) { false }

        config_accessor(:malformed_auth_handler) { proc { true } }
        config_accessor(:failed_auth_handler) { proc { true } }

        config_accessor(:authenticator) { proc { true } }
      end
    end
  end
end
