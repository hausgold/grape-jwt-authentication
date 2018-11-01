# frozen_string_literal: true

require 'rack'
require 'rack/lobster'
require 'rack/test'

# rubocop:disable RSpec/DescribeClass because we test not a specific class
RSpec.describe 'Rack usage' do
  include Rack::Test::Methods

  let(:malformed_token) { 'no.json.web.token' }
  let(:invalid_token) { 'eyJ0eXAiOiJKV1QifQ.eyJ0ZXN0IjpmYWxzZX0.' }
  let(:valid_token) { 'eyJ0eXAiOiJKV1QifQ.eyJ0ZXN0Ijp0cnVlfQ.' }

  let(:app) do
    app = Rack::Builder.new do
      use Rack::ShowExceptions
      use Rack::Lint
      use Grape::Jwt::Authentication::JwtHandler
      map '/' do
        run Rack::Lobster.new
      end
    end
    app.run(app)
  end

  before do
    Grape::Jwt::Authentication.configure do |conf|
      conf.authenticator = proc do |token|
        token == 'eyJ0eXAiOiJKV1QifQ.eyJ0ZXN0Ijp0cnVlfQ.'
      end
    end
  end

  it 'fails on missing authorization header' do
    get '/'
    expect(last_response.body).to \
      be_eql('Authorization header is malformed.')
  end

  it 'fails on a malformed authorization header' do
    header 'Authorization', "Bearer #{malformed_token}"
    get '/'
    expect(last_response.body).to \
      be_eql('Authorization header is malformed.')
  end

  it 'fails on a wrong/bad JSON Web Token' do
    header 'Authorization', "Bearer #{invalid_token}"
    get '/'
    expect(last_response.body).to \
      be_eql('Access denied.')
  end

  it 'succeeds on a fine JSON Web Token' do
    header 'Authorization', "Bearer #{valid_token}"
    get '/'
    expect(last_response.body).to match(/Lobstericious!/)
  end
end
# rubocop:enable RSpec/DescribeClass
