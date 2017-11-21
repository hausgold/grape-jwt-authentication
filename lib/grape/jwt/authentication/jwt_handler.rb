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
        def initialize(app)
          @app = app

          @conf = Grape::Jwt::Authentication.configuration
          @malformed_handler = @conf.malformed_auth_handler
          @failed_handler = @conf.failed_auth_handler
          @block = @conf.authenticator
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

        # Perform the authentication logic on the Rack compatible
        # interface.
        #
        # :reek:TooManyStatements because reek counts exception
        #                         handling as statements
        def call(env)
          # Unfortunately Grape's middleware stack orders the error
          # handling higher than the formatter. So when a error is
          # raised, the Rack env was not yet analysed and the content
          # type not negotiated. This would result in allways-JSON
          # responses on authentication errors. We want to be smarter
          # here and respond in the requested format on authentication
          # errors, that why we invoke the formatter middleware here.
          Grape::Middleware::Formatter.new(->(_) {}).call(env)

          # Parse the JWT token and give it to the user defined block
          # for futher verification. The user given block MUST return
          # a positive result to allow the request to be further
          # processed, or a negative result to stop processing.
          token = parse_token(env['HTTP_AUTHORIZATION'])
          raise AuthenticationError unless @block.call(token)

          # Looks like we are on a good path and the given token was
          # valid on all checks. So we continue the regular
          # application logic now.
          @app.call(env)
        rescue MalformedHeaderError
          # Call the user defined malformed authentication handler.
          @malformed_handler.call
        rescue AuthenticationError
          # Call the user defined failed authentication handler.
          @failed_handler.call
        end
      end
    end
  end
end
