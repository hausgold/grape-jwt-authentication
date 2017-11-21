# frozen_string_literal: true

RSpec.describe Grape::Jwt::Authentication::JwtHandler do
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
      ['auth-scheme-missing', '4r112879hd21932r'],
      ['auth-credentials-missing', 'Bearer']
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
      it 'calls the failed authentication handler' do
        conf.authenticator = proc { false }
        conf.failed_auth_handler = false_proc
        expect(false_proc).to receive(:call)
        handler.call(env)
      end
    end

    context 'when authenticator succeeds' do
      it 'calls the failed authentication handler' do
        conf.authenticator = true_proc
        conf.failed_auth_handler = false_proc
        expect(false_proc).not_to receive(:call)
        handler.call(env)
      end
    end
  end
end
