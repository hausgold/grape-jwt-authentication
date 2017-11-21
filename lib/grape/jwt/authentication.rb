# frozen_string_literal: true

require 'active_support/concern'
require 'active_support/configurable'
require 'active_support/core_ext/hash'

require 'grape'
require 'pp'

require 'grape/jwt/authentication/version'
require 'grape/jwt/authentication/configuration'
require 'grape/jwt/authentication/jwt_handler'

module Grape
  module Jwt
    # The Grape JWT authentication concern.
    module Authentication
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
      #     conf.authenticator = proc do |token|
      #       # Perform your verification logic here..
      #       # Return true/false accordingly.
      #     end
      #   end
      def self.configure
        yield(configuration)
      end

      # Reset the current configuration with the default one.
      def self.reset_configuration!
        self.configuration = Configuration.new
      end
    end
  end
end
