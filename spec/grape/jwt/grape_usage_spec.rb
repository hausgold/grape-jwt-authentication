# frozen_string_literal: true

require 'rack'
require 'rack/test'

# rubocop:disable Style/GlobalVars because of the test modules
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

    include Grape::Jwt::Authentication
    auth :jwt
  end
end

module TestContentType
  class API < Grape::API
    version 'v1', using: :path

    content_type :jsonapi, "application/vnd.api+json"
    default_format :jsonapi
    format :jsonapi


    include Grape::Jwt::Authentication
    auth :jwt, malformed: $custom_malformed_auth_handler,
         failed: $custom_failed_auth_handler,
         &$custom_authenticator


    resource :test do
      desc 'A simple GET endpoint which is JWT protected.'
      post do
        { test: true }
      end
    end
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

    include Grape::Jwt::Authentication
    auth :jwt, malformed: $custom_malformed_auth_handler,
               failed: $custom_failed_auth_handler,
         &$custom_authenticator
  end
end

RSpec.shared_examples 'api' do
  it 'fails on missing authorization header' do
    get '/v1/test'
    expect(last_response.body).to \
      be_eql('Malformed!')
  end

  it 'fails on a malformed authorization header' do
    header 'Authorization', "Bearer #{malformed_token}"
    get '/v1/test'
    expect(last_response.body).to \
      be_eql('Malformed!')
  end

  it 'fails on a wrong/bad JSON Web Token' do
    header 'Authorization', "Bearer #{invalid_token}"
    get '/v1/test'
    expect(last_response.body).to \
      be_eql('Go away!')
  end

  it 'succeeds on a fine JSON Web Token' do
    header 'Authorization', "Bearer #{valid_token}"
    get '/v1/test'
    expect(last_response.body).to be_eql('{"test":true}')
  end
end

# rubocop:disable RSpec/DescribeClass because we test not a specific class
RSpec.describe 'Grape usage' do
  let(:valid_token) { 'eyJ0eXAiOiJKV1QifQ.eyJ0ZXN0Ijp0cnVlfQ.' }
  let(:malformed_token) { 'no.json.web.token' }
  let(:invalid_token) { 'eyJ0eXAiOiJKV1QifQ.eyJ0ZXN0IjpmYWxzZX0.' }

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

    include_examples 'api'
  end

  context 'with API-local configuration' do
    let(:app) { TestLocalConfiguration::API }

    include_examples 'api'
  end

  context 'with a custom content type' do
    let(:app) { TestContentType::API }

    it 'succeeds on POST' do
      header 'Authorization', "Bearer #{valid_token}"
      header 'CONTENT_TYPE', 'application/vnd.api+json'
      header 'HTTP_ACCEPT', 'application/vnd.api+json'

      post '/v1/test',
           params: {},
           as: :json
      expect(last_response.body).to be_eql('{"test":true}')
    end
  end
end
