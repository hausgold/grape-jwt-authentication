# frozen_string_literal: true

require 'singleton'
require 'openssl'
require 'httparty'

module Grape
  module Jwt
    module Authentication
      # A common purpose RSA public key fetching/caching helper. With the help
      # of this class you are able to retrieve the RSA public key from a remote
      # server or a local file. This is naturally only useful if you care about
      # JSON Web Token which are signed by the RSA algorithm.
      class RsaPublicKey
        include Singleton

        # Setup all the getters and setters.
        attr_accessor :cache
        attr_writer :url, :expiration, :caching

        # Setup the instance.
        def initialize
          @expiration = 1.hour
          @cache = ActiveSupport::Cache::MemoryStore.new
        end

        # Just a simple shortcut class method to access the fetch method
        # without specifying the singleton instance.
        #
        # @return [OpenSSL::PKey::RSA]
        def self.fetch
          instance.fetch
        end

        # Configure the single instance. This is just a wrapper (like tap)
        # to the instance itself.
        def configure
          yield(self)
        end

        # Fetch the public key with the help of the configuration.  You can
        # configure the public key location (local file, remote (HTTP/HTTPS)
        # file), whenever we should cache and how long to cache.
        #
        # @return [OpenSSL::PKey::RSA]
        def fetch
          encoded_key = if cache?
                          cache.fetch('encoded_key', expires_in: expiration) do
                            fetch_encoded_key
                          end
                        else
                          fetch_encoded_key
                        end

          OpenSSL::PKey::RSA.new(encoded_key)
        end

        # Fetch the encoded (DER, or PEM) public key from a remote or local
        # location.
        #
        # @return [String] The encoded public key
        def fetch_encoded_key
          raise ArgumentError, 'No URL for RsaPublicKey configured' unless url

          if remote?
            HTTParty.get(url).body
          else
            File.read(url)
          end
        end

        # A helper for the caching configuration.
        #
        # @return [Boolean]
        def cache?
          caching && true
        end

        # A helper to determine if the configured URL is on a remote server or
        # it is local on the filesystem. Whenever the configured URL specifies
        # the HTTP/HTTPS protocol, we assume it is remote.
        #
        # @return [Boolean]
        def remote?
          !(url =~ /^https?/).nil?
        end

        # This getter passes back the default RSA public key.  You can change
        # this the way you like by configuring your URL with the help of the
        # same named setter.
        #
        # @return [String] The configured public key location
        def url
          unless @url
            conf = Grape::Jwt::Authentication.configuration
            return conf.rsa_public_key_url
          end
          @url
        end

        # This getter passes back the default public key cache expiration time.
        # You can change this time with the help of the same named setter.
        #
        # @return [Integer] The configured cache expiration time
        def expiration
          unless @expiration
            conf = Grape::Jwt::Authentication.configuration
            return conf.rsa_public_key_expiration
          end
          @expiration
        end

        # This getter passes back the caching flag. You can change this flag
        # with the help of the same named setter.
        #
        # @return [Boolean] Whenever we should cache or not
        def caching
          unless @caching
            conf = Grape::Jwt::Authentication.configuration
            return conf.rsa_public_key_caching
          end
          @caching
        end
      end
    end
  end
end
