# frozen_string_literal: true

RSpec.describe Grape::Jwt::Authentication::RsaPublicKey do
  let(:instance) { described_class.instance }

  before do
    instance.url = nil
    instance.caching = nil
    instance.expiration = nil
  end

  describe 'singleton' do
    it 'is a singleton implementation' do
      expect(described_class.instance).to be(instance)
    end
  end

  describe '#configure' do
    it 'yields the singleton instance' do
      expect do |block|
        instance.configure(&block)
      end.to yield_with_args(instance)
    end
  end

  describe '#url' do
    it 'delivers the default value' do
      expect(instance.url).to be_nil
    end

    it 'can be reconfigured' do
      instance.url = '/tmp/file'
      expect(instance.url).to be_eql('/tmp/file')
    end
  end

  describe '#caching' do
    it 'delivers the default value' do
      expect(instance.caching).to be(false)
    end

    it 'can be reconfigured' do
      instance.caching = true
      expect(instance.caching).to be(true)
    end
  end

  describe '#expiration' do
    it 'delivers the default value' do
      expect(instance.expiration).to be_eql(1.hour)
    end

    it 'can be reconfigured' do
      instance.expiration = 2.minutes
      expect(instance.expiration).to be_eql(2.minutes)
    end
  end

  describe '#cache?' do
    it 'detects the configuration (true)' do
      instance.caching = true
      expect(instance.cache?).to be(true)
    end

    it 'detects the configuration (false)' do
      instance.caching = false
      expect(instance.cache?).to be(false)
    end
  end

  describe '#remote?' do
    it 'detects remote URLs (http)' do
      instance.url = 'http://public.key'
      expect(instance.remote?).to be(true)
    end

    it 'detects remote URLs (https)' do
      instance.url = 'https://public.key'
      expect(instance.remote?).to be(true)
    end

    it 'detects local URLs' do
      instance.url = '/tmp/public.key'
      expect(instance.remote?).to be(false)
    end
  end

  describe '#fetch_encoded_key' do
    context 'without URL' do
      it 'raises an error' do
        instance.url = nil
        expect { instance.fetch_encoded_key }.to \
          raise_error(ArgumentError, /No URL.*configured/)
      end
    end

    context 'with remote URL' do
      it 'performs a HTTP GET request to get the public key', :vcr do
        instance.url = 'http://localhost:1337/rsa1.pub'
        expect(instance.fetch_encoded_key).to \
          be_eql(file_fixture('rsa1.pub').read)
      end
    end

    context 'with local URL' do
      it 'performs a local file read to get the public key' do
        fixture = file_fixture('rsa1.pub')
        instance.url = fixture.path
        expect(instance.fetch_encoded_key).to be_eql(fixture.read)
      end
    end
  end

  describe '#fetch' do
    let(:pub1) { file_fixture('rsa1.pub') }
    let(:pub2) { file_fixture('rsa2.pub') }
    let(:configure_pub1) { instance.url = pub1.path }
    let(:configure_pub2) { instance.url = pub2.path }

    context 'with cache' do
      it 'cache the key' do
        instance.caching = true
        configure_pub1
        expect { configure_pub2 }.not_to change { instance.fetch.to_s }
      end
    end

    context 'without cache' do
      it 'does not cache the key' do
        instance.caching = false
        configure_pub1
        expect { configure_pub2 }.to change { instance.fetch.to_s }
      end
    end
  end

  describe '.fetch' do
    it 'just shortcuts the instance method' do
      Grape::Jwt::Authentication.configure do |conf|
        conf.rsa_public_key_url = file_fixture('rsa1.pub').path
      end
      expect(described_class.fetch).to be_a(OpenSSL::PKey::RSA)
    end
  end
end
