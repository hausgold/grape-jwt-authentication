# frozen_string_literal: true

require 'recursive-open-struct'

module Grape
  module Jwt
    module Authentication
      # A easy to use model for verification of JSON Web Tokens. This is just a
      # wrapper class for the excellent ruby-jwt gem. It's completely up to you
      # to use it. But be aware, its a bit optinionated by default.
      class Jwt
        # All the following JWT verification issues lead to a failed validation.
        RESCUE_JWT_EXCEPTIONS = [
          ::JWT::DecodeError,
          ::JWT::VerificationError,
          ::JWT::ExpiredSignature,
          ::JWT::IncorrectAlgorithm,
          ::JWT::ImmatureSignature,
          ::JWT::InvalidIssuerError,
          ::JWT::InvalidIatError,
          ::JWT::InvalidAudError,
          ::JWT::InvalidSubError,
          ::JWT::InvalidJtiError,
          ::JWT::InvalidPayload
        ].freeze

        # :reek:Attribute because its fine to be extern-modifiable at these
        # instances
        attr_reader :payload, :token
        attr_writer :verification_key, :jwt_options
        attr_accessor :issuer, :beholder

        # Setup a new JWT instance. You have to pass the raw JSON Web Token to
        # the initializer. Example:
        #
        #   Jwt.new('j.w.t')
        #   # => <Jwt>
        #
        # @return [Jwt]
        def initialize(token)
          parsed_payload = JWT.decode(token, nil, false).first.symbolize_keys
          @token = token
          @payload = RecursiveOpenStruct.new(parsed_payload)
        end

        # Checks if the payload says this is a refresh token.
        #
        # @return [Boolean] Whenever this is a access token
        def access_token?
          payload.typ == 'access'
        end

        # Checks if the payload says this is a refresh token.
        #
        # @return [Boolean] Whenever this is a refresh token
        def refresh_token?
          payload.typ == 'refresh'
        end

        # Retrives the expiration date from the payload when set.
        #
        # @return [nil|ActiveSupport::TimeWithZone] The expiration date
        def expires_at
          exp = payload.exp
          return nil unless exp

          Time.zone.at(exp)
        end

        # Deliver the public key for verification by default. This uses the
        # {RsaPublicKey} class, but you can configure the verification key the
        # way you like. (Especially for different algorithms, like HMAC or
        # ECDSA) Just make use of the same named setter.
        #
        # @return [OpenSSL::PKey::RSA|Mixed] The verification key
        def verification_key
          unless @verification_key
            conf = Grape::Jwt::Authentication.configuration
            return conf.jwt_verification_key.call
          end
          @verification_key
        end

        # This getter passes back the default JWT verification option hash
        # which is optinionated.  You can change this the way you like by
        # configuring your options with the help of the same named setter.
        #
        # @return [Hash] The JWT verification options hash
        def jwt_options
          unless @jwt_options
            conf = Grape::Jwt::Authentication.configuration
            return conf.jwt_options.call
          end
          @jwt_options
        end

        # Verify the current token by our hard and strict rules. Whenever the
        # token was not parsed from a string, we encode the current state to a
        # JWT string representation and check this.
        #
        # @return [Boolean] Whenever the token is valid or not
        #
        # :reek:NilCheck because we have to check the token
        #                origin and react on it
        def valid?
          JWT.decode(token, verification_key, true, jwt_options) && true
        rescue *RESCUE_JWT_EXCEPTIONS
          false
        end
      end
    end
  end
end
