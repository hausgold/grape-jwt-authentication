# frozen_string_literal: true

def new_token(**payload)
  encoded_header = Base64.urlsafe_encode64({ typ: 'JWT' }.to_json)
  encoded_payload = Base64.urlsafe_encode64(payload.to_json)
  "#{encoded_header}.#{encoded_payload}"
end

def new_signed_token(custom_private_key: nil, **payload)
  key = custom_private_key || private_key
  JWT.encode(payload.to_h, key, 'RS256')
end

RSpec.describe Grape::Jwt::Authentication::Jwt do
  let(:private_key) { OpenSSL::PKey::RSA.new(2048) }
  let(:public_key) { private_key.public_key }
  let(:unsigned_instance) { described_class.new(new_token(test: true)) }
  let(:unsigned_access_instance) do
    described_class.new(new_token(typ: 'access'))
  end
  let(:unsigned_refresh_instance) do
    described_class.new(new_token(typ: 'refresh'))
  end

  describe '#initialize' do
    it 'passes back a new described_class instance' do
      expect(described_class.new(new_token)).to \
        be_a(described_class)
    end

    it 'makes the original token available' do
      expect(described_class.new(new_token).token).to \
        be_eql(new_token)
    end

    it 'makes the payload available' do
      expect(described_class.new(new_token(test: true)).payload.test).to \
        be(true)
    end
  end

  describe '#verification_key' do
    before do
      key = Grape::Jwt::Authentication::RsaPublicKey.instance
      key.url = file_fixture('rsa1.pub').path
    end

    it 'sets the verification key on instantiation' do
      expect(unsigned_instance.verification_key).to be_a(OpenSSL::PKey::RSA)
    end

    it 'the verification key is PEM encoded' do
      expect(unsigned_instance.verification_key.to_s).to match(/\w\d+/)
    end

    it 'can be reconfigured' do
      key = OpenSSL::PKey::RSA.new(2048).public_key
      unsigned_instance.verification_key = key
      expect(unsigned_instance.verification_key.to_s).to be_eql(key.to_s)
    end
  end

  describe '#jwt_options' do
    it 'delivers the default hash' do
      expect(unsigned_instance.jwt_options).to be_a(Hash)
    end

    it 'can be reconfigured' do
      unsigned_instance.jwt_options = { algorithm: 'HS256' }
      expect(unsigned_instance.jwt_options).to include(algorithm: 'HS256')
    end
  end

  describe '#payload' do
    it 'converts the payload to a open struct' do
      expect(unsigned_instance.payload).to be_a(RecursiveOpenStruct)
    end

    it 'uses the given symbol arguments for the payload' do
      expect(unsigned_instance.payload.test).to be(true)
    end
  end

  describe '#access_token?' do
    it 'detects the type property correctly (true)' do
      expect(unsigned_access_instance.access_token?).to be(true)
    end

    it 'detects the type property correctly (false)' do
      expect(unsigned_refresh_instance.access_token?).to be(false)
    end

    it 'detects the type property correctly (false, unset)' do
      expect(unsigned_instance.access_token?).to be(false)
    end
  end

  describe '#refresh_token?' do
    it 'detects the type property correctly (true)' do
      expect(unsigned_refresh_instance.refresh_token?).to be(true)
    end

    it 'detects the type property correctly (false)' do
      expect(unsigned_access_instance.refresh_token?).to be(false)
    end

    it 'detects the type property correctly (false, unset)' do
      expect(unsigned_instance.refresh_token?).to be(false)
    end
  end

  describe '#expires_at' do
    before { Timecop.freeze }
    after { Timecop.return }

    it 'exports the expiration date when set' do
      jwt = new_token(exp: 1.hour.from_now.to_i)
      expect(described_class.new(jwt).expires_at).to \
        be_a(ActiveSupport::TimeWithZone)
    end

    it 'exports nil when not set' do
      jwt = new_token(exp: nil)
      expect(described_class.new(jwt).expires_at).to be_nil
    end

    it 'exports the correct date' do
      at = 1.hour.from_now.change(usec: 0)
      jwt = new_token(exp: at.to_i)
      expect(described_class.new(jwt).expires_at).to \
        be_eql(at)
    end
  end

  describe '#valid?' do
    let(:issuer) { 'test-issuer' }
    let(:audience) { %w[beholder1 beholder2] }
    let(:payload) do
      { iss: issuer,
        iat: Time.now.to_i,
        exp: 1.hour.from_now.to_i,
        aud: audience }
    end
    let(:valid) { new_signed_token(payload) }
    let(:wrong_issuer) { new_signed_token(payload.merge(iss: 'wrong')) }
    let(:expired) { new_signed_token(payload.merge(exp: 1.week.ago.to_i)) }
    let(:wrong_audience) { new_signed_token(payload.merge(aud: 'wrong')) }
    let(:missing_issued_at) { new_signed_token(payload.merge(iat: nil)) }
    let(:invalid_sign) do
      key = OpenSSL::PKey::RSA.new(2048)
      new_signed_token(custom_private_key: key, **payload)
    end
    let(:manipulated_payload) do
      parts = new_signed_token(payload).split('.')
      new_payload = Base64.urlsafe_encode64({ test: true }.to_json)
      "#{parts.first}.#{new_payload}.#{parts.last}"
    end

    def configure_valid
      Grape::Jwt::Authentication.configure do |conf|
        conf.jwt_issuer = issuer
        conf.jwt_beholder = audience.first
        conf.jwt_verification_key = -> { public_key }
      end
    end

    [
      ['wrong issuer', :wrong_issuer],
      ['expired token', :expired],
      ['wrong audience', :wrong_audience],
      ['invalid signing', :invalid_sign],
      ['manipulated payloads', :manipulated_payload]
    ].each do |desc, token_name|
      it "detects #{desc}" do
        token = described_class.new(send(token_name))
        configure_valid
        expect(token.valid?).to be(false)
      end
    end

    it 'detects missing issues at' do
      pending 'https://github.com/jwt/ruby-jwt/issues/247'
      token = described_class.new(missing_issued_at)
      configure_valid
      expect(token.valid?).to be(false)
    end

    it 'detects valid tokens' do
      token = described_class.new(new_signed_token(payload))
      configure_valid
      expect(token.valid?).to be(true)
    end
  end
end
