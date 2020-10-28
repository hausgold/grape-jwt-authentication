# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'grape/jwt/authentication/version'

Gem::Specification.new do |spec|
  spec.name          = 'grape-jwt-authentication'
  spec.version       = Grape::Jwt::Authentication::VERSION
  spec.authors       = ['Hermann Mayer']
  spec.email         = ['hermann.mayer92@gmail.com']

  spec.summary       = 'A reusable Grape JWT authentication concern'
  spec.description   = 'A reusable Grape JWT authentication concern'
  spec.homepage      = 'https://github.com/hausgold/grape-jwt-authentication'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '>= 1.16', '< 3'
  spec.add_development_dependency 'rack', '~> 2.0'
  spec.add_development_dependency 'rack-test', '~> 0.8.2'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.9'
  # TODO: Remove this pinning, when the broken 3.9.3 is fixed.
  #       See: https://github.com/rspec/rspec-expectations/issues/1221
  spec.add_development_dependency 'rspec-expectations', '<= 3.9.2'
  spec.add_development_dependency 'simplecov', '~> 0.15'
  spec.add_development_dependency 'timecop', '~> 0.9.1'
  spec.add_development_dependency 'vcr', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 3.1'

  spec.add_runtime_dependency 'activesupport', '>= 3.2.0'
  spec.add_runtime_dependency 'grape', '~> 1.0'
  spec.add_runtime_dependency 'httparty'
  spec.add_runtime_dependency 'jwt', '~> 2.1'
  spec.add_runtime_dependency 'recursive-open-struct', '~> 1.0'
  spec.add_runtime_dependency 'keyless', '~> 1.0'
end
