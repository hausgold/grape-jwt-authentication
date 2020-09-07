# frozen_string_literal: true

module Grape
  module Jwt
    module Authentication
      # Specifies which configuration keys are shared between keyless
      # and grape-jwt-authentication, so that we can easily pass through
      # our configuration to keyless.
      KEYLESS_CONFIGURATION = %i[
        authenticator rsa_public_key_url rsa_public_key_caching
        rsa_public_key_expiration jwt_issuer jwt_beholder jwt_options
        jwt_verification_key
      ]

      # (Re)configure our gem dependencies. We take care of setting up
      # +Keyless+, which has been extracted from this gem.
      def self.configure_dependencies
        configure_keyless
      end

      # Configure the +Keyless+ gem with our configuration.
      def self.configure_keyless
        configuration = Grape::Jwt::Authentication.configuration

        Keyless.configure do |keyless|
          KEYLESS_CONFIGURATION.each do |option|
            keyless.send("#{option}=", configuration.send(option))
          end
        end
      end
    end
  end
end
