# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Grape::Jwt::Authentication::JwtHandler do
  let(:jwt) { JWT.encode({ test: true }, nil, 'none') }
  let(:conf) { Grape::Jwt::Authentication.configuration }
  let(:true_proc) { proc { true } }
  let(:false_proc) { proc { false } }
  let(:handler) do
    app = {}
    allow(app).to receive(:call)
    described_class.new(app)
  end

  describe 'malformed authorization header' do
    [
      ['empty', ''],
      ['mixed', 'Bearer token="7601065c39d6c3fe31cb893eee"'],
      %w[concat Bearer7601065c39d6c3fe31cb893eee],
      ['token-option-only', 'Token option_a="value_a"'],
      %w[auth-scheme-missing 4r112879hd21932r],
      %w[auth-credentials-missing Bearer]
    ].each do |data|
      let(:env) { { 'HTTP_AUTHORIZATION' => data.last } }

      it "calls the malformed auth handler (#{data.first})" do
        conf.malformed_auth_handler = false_proc
        expect(false_proc).to receive(:call)
        handler.call(env)
      end
    end
  end

  describe 'well-formed authorization header' do
    let(:env) { { 'HTTP_AUTHORIZATION' => 'Bearer a.b.c' } }

    context 'when authenticator fails' do
      before do
        conf.authenticator = proc { false }
        conf.failed_auth_handler = false_proc
      end

      it 'calls the failed authentication handler' do
        expect(false_proc).to receive(:call)
        handler.call(env)
      end

      it 'injects the original token into the rack env' do
        expect { handler.call(env) }.to \
          change { env['grape_jwt_auth.original_token'] }.from(nil).to('a.b.c')
      end

      it 'injects the parsed token into the rack env' do
        expect { handler.call(env) }.to \
          change { env.key? 'grape_jwt_auth.parsed_token' }.from(false).to(true)
      end
    end

    context 'when authenticator succeeds' do
      let(:env) { { 'HTTP_AUTHORIZATION' => "Bearer #{jwt}" } }

      before do
        conf.authenticator = true_proc
        conf.failed_auth_handler = false_proc
      end

      it 'calls the failed authentication handler' do
        expect(false_proc).not_to receive(:call)
        handler.call(env)
      end

      it 'injects the original token into the rack env' do
        expect { handler.call(env) }.to \
          change { env['grape_jwt_auth.original_token'] }.from(nil).to(jwt)
      end

      it 'injects the parsed token into the rack env' do
        expect { handler.call(env) }.to \
          change { env['grape_jwt_auth.parsed_token'] }
          .from(nil).to(Keyless::Jwt)
      end

      it 'inject the parsed token which makes the payload accessible' do
        handler.call(env)
        expect(env['grape_jwt_auth.parsed_token'].payload).to \
          eql(RecursiveOpenStruct.new(test: true))
      end
    end
  end
end
