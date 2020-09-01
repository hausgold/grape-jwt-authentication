# frozen_string_literal: true

require 'active_support'
require 'active_support/concern'
require 'active_support/configurable'
require 'active_support/cache'
require 'active_support/core_ext/hash'
require 'active_support/time'
require 'active_support/time_with_zone'

require 'jwt'

require 'keyless'
require 'grape'
require 'grape/jwt/authentication/version'
require 'grape/jwt/authentication/configuration'
require 'grape/jwt/authentication/jwt_handler'

module Grape
  module Jwt
    # The Grape JWT authentication concern.
    module Authentication
      extend ActiveSupport::Concern
      include Grape::DSL::API

      class << self
        attr_writer :configuration
      end

      # Retrieve the current configuration object.
      #
      # @return [Configuration]
      def self.configuration
        @configuration ||= Configuration.new
      end

      # Configure the concern by providing a block which takes
      # care of this task. Example:
      #
      #   Grape::Jwt::Authentication.configure do |conf|
      #     # conf.xyz = [..]
      #   end
      def self.configure
        yield(configuration)
      end

      # Reset the current configuration with the default one.
      def self.reset_configuration!
        self.configuration = Configuration.new
      end

      included do
        # Configure a new Grape authentication strategy which will be
        # backed by the JwtHandler middleware. We do not want
        # gem-internal claim verification or database lookup
        # functionality. Let the user handle this the way he want.
        Grape::Middleware::Auth::Strategies.add(:jwt,
                                                JwtHandler,
                                                ->(opts) { [opts] })

        helpers do
          # Get the parsed JWT from the authorization header of the current
          # request. You could use it to access the payload or the expiration
          # date, etc inside your API definition. When the authenticator stated
          # that the validation failed, then the parsed token is +nil+.
          #
          # @return [Grape::Jwt::Authentication::Jwt, nil] the parsed token
          def request_jwt
            env['grape_jwt_auth.parsed_token']
          end

          # Get the original JWT from the authorization header of the current
          # request, without further changes. You could use it to display a
          # custom error or to parse it differently.
          #
          # @return [String] the JWT from the authorization header
          def original_request_jwt
            env['grape_jwt_auth.original_token']
          end
        end
      end
    end
  end
end
