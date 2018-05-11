# frozen_string_literal: true

module Grape
  module Jwt
    module Authentication
      # Take care of the token validation and verification on this
      # Rack middleware. It is a self contained implementation of a
      # valid Rack handler which checks for a common JWT token
      # Authorization header and calls a user given verification block
      # which performs the database lookup or whatever is necessary
      # for the verification.
      class JwtHandler
        # A internal exception handling for failed authentications.
        class AuthenticationError < StandardError; end
        # A internal exception handling for malformed headers.
        class MalformedHeaderError < StandardError; end

        # A common JWT validation regex which meets the RFC specs.
        JWT_REGEX = /^[a-zA-Z0-9\-_]+?\.[a-zA-Z0-9\-_]+?\.([a-zA-Z0-9\-_]+)?$/

        # Initialize a new Rack middleware for Bearer token
        # processing.
        #
        # @param app [Proc] The regular Rack application
        # @param options [Hash] A global-overwritting configuration hash
        def initialize(app, options = {})
          @app = app
          @options = options
        end

        # A shared configuration lookup helper which selects the requested
        # entry from the local or global configuration object.  The local
        # configuration takes presedence over the global one.
        #
        # @param key [Symbol] The local config key
        # @param global_key [Symbol] The global config key
        # @return [Mixed] The configuration value
        def config(key, global_key)
          block = @options[key]
          unless block
            global_conf = Grape::Jwt::Authentication.configuration
            return global_conf.send(global_key)
          end
          block
        end

        # Get the local or global defined authenticator for the JWT handler.
        #
        # @return [Proc] The authenticator block
        def authenticator
          config(:proc, :authenticator)
        end

        # Get the local or global defined malformed authentication handler for
        # the JWT handler.
        #
        # @return [Proc] The malformed authorization handler block
        def malformed_handler
          config(:malformed, :malformed_auth_handler)
        end

        # Get the local or global defined failed authentication handler for the
        # JWT handler.
        #
        # @return [Proc] The failed authentication handler block
        def failed_handler
          config(:failed, :failed_auth_handler)
        end

        # Validate the Bearer authentication scheme on the given
        # authorization header and validate the JWT token when it was
        # found.
        #
        # @param header [String] The authorization header value
        # @return [String] The parsed and well-formatted JWT
        def parse_token(header)
          token = header.to_s.scan(/^Bearer (.*)/).flatten.first
          raise MalformedHeaderError unless JWT_REGEX =~ token
          token
        end

        def app_options
          return @app.options if @app.instance_of?(Grape::Middleware::Formatter)
          return @app.app.options if @app.respond_to?(:app) &&  @app.app&.instance_of?(Grape::Middleware::Formatter)
          {}
        end

        # Perform the authentication logic on the Rack compatible
        # interface.
        #
        # :reek:TooManyStatements because reek counts exception
        #                         handling as statements
        def call(env)
          # Unfortunately Grape's middleware stack orders the error
          # handling higher than the formatter. So when a error is
          # raised, the Rack env was not yet analysed and the content
          # type not negotiated. This would result in always-JSON
          # responses on authentication errors. We want to be smarter
          # here and respond in the requested format on authentication
          # errors, that why we invoke the formatter middleware here.
          Grape::Middleware::Formatter.new(->(_) {}, app_options).call(env)

          # Parse the JWT token and give it to the user defined block
          # for futher verification. The user given block MUST return
          # a positive result to allow the request to be further
          # processed, or a negative result to stop processing.
          token = parse_token(env['HTTP_AUTHORIZATION'])
          raise AuthenticationError unless authenticator.call(token)

          # Looks like we are on a good path and the given token was
          # valid on all checks. So we continue the regular
          # application logic now.
          @app.call(env)
        rescue MalformedHeaderError
          # Call the user defined malformed authentication handler.
          malformed_handler.call(env['HTTP_AUTHORIZATION'], @app)
        rescue AuthenticationError
          # Call the user defined failed authentication handler.
          failed_handler.call(token, @app)
        end
      end
    end
  end
end
