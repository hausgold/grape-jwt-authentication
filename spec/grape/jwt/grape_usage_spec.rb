# frozen_string_literal: true

require 'spec_helper'
require 'rack'
require 'rack/test'

# rubocop:disable Style/GlobalVars -- because of the test modules
$custom_authenticator = proc do |token|
  token == 'eyJ0eXAiOiJKV1QifQ.eyJ0ZXN0Ijp0cnVlfQ.'
end
$custom_malformed_auth_handler = proc do |_raw_token, _app|
  [400, {}, ['Malformed!']]
end
$custom_failed_auth_handler = proc do |_token, _app|
  [401, {}, ['Go away!']]
end

module TestGlobalConfiguration
  class API < Grape::API
    version 'v1', using: :path
    format :json

    resource :test do
      desc 'A simple GET endpoint which is JWT protected.'
      get do
        { test: true }
      end
    end

    resource :payload do
      desc 'A JWT payload echo service.'
      get do
        { payload: request_jwt.payload.to_h }
      end
    end

    resource :token do
      desc 'A JWT echo service.'
      get do
        { token: original_request_jwt }
      end
    end

    include Grape::Jwt::Authentication

    auth :jwt
  end
end

module TestLocalConfiguration
  class API < Grape::API
    version 'v1', using: :path
    format :json

    resource :test do
      desc 'A simple GET endpoint which is JWT protected.'
      get do
        { test: true }
      end
    end

    resource :payload do
      desc 'A JWT payload echo service.'
      get do
        { payload: request_jwt.payload.to_h }
      end
    end

    resource :token do
      desc 'A JWT echo service.'
      get do
        { token: original_request_jwt }
      end
    end

    include Grape::Jwt::Authentication

    auth :jwt, malformed: $custom_malformed_auth_handler,
               failed: $custom_failed_auth_handler,
         &$custom_authenticator
  end
end

RSpec.shared_examples 'api' do
  let(:malformed_token) { 'no.json.web.token' }
  let(:invalid_token) { 'eyJ0eXAiOiJKV1QifQ.eyJ0ZXN0IjpmYWxzZX0.' }
  let(:valid_token) { 'eyJ0eXAiOiJKV1QifQ.eyJ0ZXN0Ijp0cnVlfQ.' }

  it 'fails on missing authorization header' do
    get '/v1/test'
    expect(last_response.body).to \
      eql('Malformed!')
  end

  it 'fails on a malformed authorization header' do
    header 'Authorization', "Bearer #{malformed_token}"
    get '/v1/test'
    expect(last_response.body).to \
      eql('Malformed!')
  end

  it 'fails on a wrong/bad JSON Web Token' do
    header 'Authorization', "Bearer #{invalid_token}"
    get '/v1/test'
    expect(last_response.body).to \
      eql('Go away!')
  end

  it 'succeeds on a fine JSON Web Token' do
    header 'Authorization', "Bearer #{valid_token}"
    get '/v1/test'
    expect(last_response.body).to eql('{"test":true}')
  end

  it 'succeeds on a lowercase authorization header' do
    header 'authorization', "Bearer #{valid_token}"
    get '/v1/test'
    expect(last_response.body).to eql('{"test":true}')
  end

  describe 'helpers' do
    describe '#original_request_jwt' do
      it 'echos the JWT' do
        header 'Authorization', "Bearer #{valid_token}"
        get '/v1/token'
        expect(last_response.body).to eql(%({"token":"#{valid_token}"}))
      end
    end

    describe '#request_jwt' do
      it 'echos the JWT payload' do
        header 'Authorization', "Bearer #{valid_token}"
        get '/v1/payload'
        expect(last_response.body).to eql(%({"payload":{"test":true}}))
      end
    end
  end
end

# rubocop:disable RSpec/DescribeClass -- because we test not a specific class
RSpec.describe 'Grape usage' do
  include Rack::Test::Methods

  before { Grape::Jwt::Authentication.reset_configuration! }

  context 'with global configuration' do
    let(:app) { TestGlobalConfiguration::API }

    before do
      Grape::Jwt::Authentication.configure do |conf|
        conf.authenticator = $custom_authenticator
        conf.malformed_auth_handler = $custom_malformed_auth_handler
        conf.failed_auth_handler = $custom_failed_auth_handler
      end
    end

    it_behaves_like 'api'
  end

  context 'with API-local configuration' do
    let(:app) { TestLocalConfiguration::API }

    it_behaves_like 'api'
  end
end
# rubocop:enable RSpec/DescribeClass
# rubocop:enable Style/GlobalVars
