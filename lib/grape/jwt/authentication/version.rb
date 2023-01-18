# frozen_string_literal: true

module Grape
  module Jwt
    # The gem version details.
    module Authentication
      # The version of the +grape-jwt-authentication+ gem
      VERSION = '2.1.0'

      class << self
        # Returns the version of gem as a string.
        #
        # @return [String] the gem version as string
        def version
          VERSION
        end

        # Returns the version of the gem as a +Gem::Version+.
        #
        # @return [Gem::Version] the gem version as object
        def gem_version
          Gem::Version.new VERSION
        end
      end
    end
  end
end
