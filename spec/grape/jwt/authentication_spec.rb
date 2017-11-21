# frozen_string_literal: true

RSpec.describe Grape::Jwt::Authentication do
  it 'has a version number' do
    expect(Grape::Jwt::Authentication::VERSION).not_to be nil
  end

  describe 'configuration' do
    it 'allows the access of the configuration' do
      expect(described_class.configuration).not_to be_nil
    end

    %w[authenticator
       malformed_auth_handler
       failed_auth_handler].each do |proc_prop|

      it "allows the configuration of the #{proc_prop}" do
        expect do
          described_class.configure do |conf|
            conf.send("#{proc_prop}=".to_s, proc { false })
          end
        end.to change { described_class.configuration.send(proc_prop.to_s) }
      end
    end

    it 'allows the configuration of the rsa_public_key_url' do
      expect do
        described_class.configure do |conf|
          conf.rsa_public_key_url = 'http://url.to.public.key'
        end
      end.to change { described_class.configuration.rsa_public_key_url }
    end

    it 'allows the configuration of the cache_rsa_public_key' do
      expect do
        described_class.configure do |conf|
          conf.cache_rsa_public_key = true
        end
      end.to change { described_class.configuration.cache_rsa_public_key }
    end

    it 'allows the reset of the configuration' do
      described_class.configuration.rsa_public_key_url = 'something else'
      expect { described_class.reset_configuration! }.to \
        change { described_class.configuration.rsa_public_key_url } \
        .from('something else').to(nil)
    end
  end
end
