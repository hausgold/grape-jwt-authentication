# frozen_string_literal: true

require 'zeitwerk'
require 'logger'
require 'active_support'
require 'active_support/concern'
require 'active_support/cache'
require 'active_support/ordered_options'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/hash'
require 'active_support/time'
require 'active_support/time_with_zone'
require 'jwt'
require 'keyless'
require 'grape'

module Grape
  module Jwt
    # The Grape JWT authentication concern.
    module Authentication
      extend ActiveSupport::Concern
      include Grape::DSL::API

      # Setup a Zeitwerk autoloader instance and configure it
      loader = Zeitwerk::Loader.for_gem_extension(Grape::Jwt)

      # Finish the auto loader configuration
      loader.setup

      # Make sure to eager load all constants
      loader.eager_load

      class << self
        attr_writer :configuration

        # Include top-level features
        include Extensions::Dependencies

        # Retrieve the current configuration object.
        #
        # @return [Configuration]
        def configuration
          @configuration ||= Configuration.new
        end

        # Configure the concern by providing a block which takes
        # care of this task. Example:
        #
        #   Grape::Jwt::Authentication.configure do |conf|
        #     # conf.xyz = [..]
        #   end
        def configure
          yield(configuration)
          configure_dependencies
        end

        # Reset the current configuration with the default one.
        def reset_configuration!
          self.configuration = Configuration.new
          configure_dependencies
        end
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
          # @return [Keyless::Jwt, nil] the parsed token
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
