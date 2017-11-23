# frozen_string_literal: true

RSpec.describe Grape::Jwt::Authentication do
  it 'has a version number' do
    expect(Grape::Jwt::Authentication::VERSION).not_to be nil
  end

  describe 'configuration' do
    it 'allows the access of the configuration' do
      expect(described_class.configuration).not_to be_nil
    end

    describe '#configure' do
      it 'yields the configuration' do
        expect do |block|
          described_class.configure(&block)
        end.to yield_with_args(described_class.configuration)
      end
    end

    describe '#reset_configuration!' do
      it 'resets the configuration to its defaults' do
        described_class.configuration.jwt_issuer = 'test'
        expect { described_class.reset_configuration! }.to \
          change { described_class.configuration.jwt_issuer }
      end
    end
  end
end
