# frozen_string_literal: true

require 'rack'
require 'rack/test'

# Our Grape API ..
module Test
  class API < Grape::API
    version 'v1', using: :path
    format :json

    resource :test do
      desc 'A simple GET endpoint which is JWT protected.'
      get do
        { test: true }
      end
    end

    include Grape::Jwt::Authentication
    auth :jwt

    rescue_from ArgumentError do |exception|
      error! exception.message
    end
  end
end

# Our token signing helper
def signed_token(**payload)
  payload = {
    iss: 'The Identity Provider',
    iat: Time.now.to_i,
    exp: 1.hour.from_now.to_i,
    aud: ['example-api', 'user-api', 'calendar-api']
  }.merge(payload)
  private_key = OpenSSL::PKey::RSA.new(file_fixture('rsa1').read)
  JWT.encode(payload.to_h, private_key, 'RS256')
end

# rubocop:disable RSpec/DescribeClass because we test not a specific class
RSpec.describe 'RSA optinionated usage' do
  include Rack::Test::Methods

  before do
    # Our initializer ..
    Grape::Jwt::Authentication.configure do |conf|
      # The local RSA public key location.
      conf.rsa_public_key_url = file_fixture('rsa1.pub')

      # Configure the JWT wrapper.
      conf.jwt_issuer = 'The Identity Provider'
      conf.jwt_beholder = 'example-api'

      # Let Grape handle the malformed error with correct response formatting.
      # (XML, JSON)
      conf.malformed_auth_handler = proc do |_raw_token, _app|
        raise ArgumentError, 'Malformed.'
      end

      # The same procedure for failed verifications. (XML, JSON formatting
      # handled external by Grape)
      conf.failed_auth_handler = proc do |_token, _app|
        raise ArgumentError, 'Denied.'
      end

      # Custom verification logic.
      conf.authenticator = proc do |token|
        # Parse and instantiate a JWT verification instance
        jwt = Grape::Jwt::Authentication::Jwt.new(token)

        # We just allow valid access tokens
        jwt.access_token? && jwt.valid?
      end
    end
  end

  let(:app) { Test::API }
  let(:malformed_token) { 'no.json.web.token' }
  let(:invalid_token) { signed_token(typ: 'refresh') }
  let(:valid_token) { signed_token(typ: 'access') }

  it 'fails on missing authorization header' do
    get '/v1/test'
    expect(last_response.body).to \
      be_eql('Malformed.')
  end

  it 'fails on a malformed authorization header' do
    header 'Authorization', "Bearer #{malformed_token}"
    get '/v1/test'
    expect(last_response.body).to \
      be_eql('Malformed.')
  end

  it 'fails on a wrong/bad JSON Web Token' do
    header 'Authorization', "Bearer #{invalid_token}"
    get '/v1/test'
    expect(last_response.body).to \
      be_eql('Denied.')
  end

  it 'succeeds on a fine JSON Web Token' do
    header 'Authorization', "Bearer #{valid_token}"
    get '/v1/test'
    expect(last_response.body).to be_eql('{"test":true}')
  end
end
