# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'grape/jwt/authentication/version'

Gem::Specification.new do |spec|
  spec.name = 'grape-jwt-authentication'
  spec.version = Grape::Jwt::Authentication::VERSION
  spec.authors = ['Hermann Mayer']
  spec.email = ['hermann.mayer92@gmail.com']

  spec.license = 'MIT'
  spec.summary = 'A reusable Grape JWT authentication concern'
  spec.description = 'A reusable Grape JWT authentication concern'

  base_uri = "https://github.com/hausgold/#{spec.name}"
  spec.metadata = {
    'homepage_uri' => base_uri,
    'source_code_uri' => base_uri,
    'changelog_uri' => "#{base_uri}/blob/master/CHANGELOG.md",
    'bug_tracker_uri' => "#{base_uri}/issues",
    'documentation_uri' => "https://www.rubydoc.info/gems/#{spec.name}"
  }

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7'

  spec.add_dependency 'activesupport', '>= 6.1'
  spec.add_dependency 'grape', '>= 1.0', '< 3.0'
  spec.add_dependency 'httparty', '>= 0.21'
  spec.add_dependency 'jwt', '~> 2.6'
  spec.add_dependency 'keyless', '~> 1.4'
  spec.add_dependency 'recursive-open-struct', '~> 2.0'
end
