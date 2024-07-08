# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/DescribeClass because there is no class/module here
RSpec.describe 'Dependency pass-through' do
  let(:described_class) { Grape::Jwt::Authentication }

  describe '.configure' do
    before do
      # Reset the jwt_issuer before running the specs to make sure changes
      # don't just come from the spec run order
      described_class.configure { |config| config.jwt_issuer = '' }
    end

    let(:action) do
      described_class.configure { |config| config.jwt_issuer = 'RSpec' }
    end

    it 'calls configure_dependencies' do
      expect(described_class).to receive(:configure_dependencies)
      action
    end

    it 'sets the keyless configuration after yielding' do
      expect { action }.to \
        change { Keyless.configuration.jwt_issuer }.from('').to('RSpec')
    end
  end

  describe '.configure_dependencies' do
    after { described_class.configure_dependencies }

    it 'calls configure_keyless' do
      expect(described_class).to receive(:configure_keyless).once
    end
  end

  describe '.configure_keyless' do
    after { described_class.configure_keyless }

    %i[
      authenticator rsa_public_key_url rsa_public_key_caching
      rsa_public_key_expiration jwt_issuer jwt_beholder jwt_options
      jwt_verification_key
    ].each do |option|
      it "sets the '#{option}' option" do
        expect(Keyless.configuration).to receive(:"#{option}=")
      end
    end
  end
end
# rubocop:enable RSpec/DescribeClass
