# frozen_string_literal: true

RSpec.describe Grape::Jwt::Authentication::Configuration do
  let(:instance) { described_class.new }

  %w[authenticator
     malformed_auth_handler
     failed_auth_handler
     jwt_options
     jwt_verification_key].each do |proc_prop|

    it "allows the configuration of the #{proc_prop}" do
      expect do
        instance.send("#{proc_prop}=", proc { false })
      end.to change { instance.send(proc_prop) }
    end
  end

  %w[rsa_public_key_url
     rsa_public_key_caching
     rsa_public_key_expiration
     jwt_issuer
     jwt_beholder].each do |prop|

    it "allows the configuration of the #{prop}" do
      expect do
        instance.send("#{prop}=", 'new value')
      end.to change { instance.send(prop) }
    end
  end
end
