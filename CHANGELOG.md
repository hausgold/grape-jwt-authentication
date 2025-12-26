### next

* TODO: Replace this bullet point with an actual description of a change.

### 3.5.0 (26 December 2025)

* Added Ruby 4.0 support ([#32](https://github.com/hausgold/grape-jwt-authentication/pull/32))
* Dropped Ruby 3.2 and Rails 7.1 support ([#31](https://github.com/hausgold/grape-jwt-authentication/pull/31))

### 3.4.0 (19 December 2025)

* Migrated to a shared Rubocop configuration for HAUSGOLD gems ([#30](https://github.com/hausgold/grape-jwt-authentication/pull/30))

### 3.3.0 (16 December 2025)

* Dropped the unused `httparty` gem ([#29](https://github.com/hausgold/grape-jwt-authentication/pull/29))

### 3.2.0 (2 December 2025)

* Added appraisals for Grape 1, 2 and 3 and loosed up the version requirement
  to `>= 1, < 4.0` ([#28](https://github.com/hausgold/grape-jwt-authentication/pull/28))
* Loosed up the version requirement for the `jwt` gem to `>= 2.6`, so people
  can [migrate to
  3.0+](https://github.com/jwt/ruby-jwt/blob/v3.1.2/UPGRADING.md) ([#28](https://github.com/hausgold/grape-jwt-authentication/pull/28))

### 3.1.0 (23 October 2025)

* Dropped Reek ([#24](https://github.com/hausgold/grape-jwt-authentication/pull/24))
* Added support for Rails 8.1 ([#25](https://github.com/hausgold/grape-jwt-authentication/pull/25))
* Switched from `ActiveSupport::Configurable` to a custom implementation based
  on `ActiveSupport::OrderedOptions` ([#26](https://github.com/hausgold/grape-jwt-authentication/pull/26))

### 3.0.0 (28 June 2025)

* Corrected some RuboCop glitches ([#21](https://github.com/hausgold/grape-jwt-authentication/pull/21))
* Drop Ruby 2 and end of life Rails (<7.1) ([#22](https://github.com/hausgold/grape-jwt-authentication/pull/22))

### 2.8.1 (21 May 2025)

* Corrected some RuboCop glitches ([#19](https://github.com/hausgold/grape-jwt-authentication/pull/19))
* Upgraded the rubocop dependencies ([#20](https://github.com/hausgold/grape-jwt-authentication/pull/20))

### 2.8.0 (30 January 2025)

* Added all versions up to Ruby 3.4 to the CI matrix ([#19](https://github.com/hausgold/grape-jwt-authentication/pull/19))

### 2.7.1 (17 January 2025)

* Added the logger dependency ([#18](https://github.com/hausgold/grape-jwt-authentication/pull/18))

### 2.7.0 (11 January 2025)

* Switched to Zeitwerk as autoloader ([#17](https://github.com/hausgold/grape-jwt-authentication/pull/17))

### 2.6.0 (3 January 2025)

* Raised minimum supported Ruby/Rails version to 2.7/6.1 ([#16](https://github.com/hausgold/grape-jwt-authentication/pull/16))

### 2.5.0 (4 October 2024)

* Upgraded the `recursive-open-struct` gem to `~> 2.0` ([#15](https://github.com/hausgold/grape-jwt-authentication/pull/15))

### 2.4.5 (15 August 2024)

* Just a retag of 2.4.1

### 2.4.4 (15 August 2024)

* Just a retag of 2.4.1

### 2.4.3 (15 August 2024)

* Just a retag of 2.4.1

### 2.4.2 (9 August 2024)

* Just a retag of 2.4.1

### 2.4.1 (9 August 2024)

* Added API docs building to continuous integration ([#14](https://github.com/hausgold/grape-jwt-authentication/pull/14))

### 2.4.0 (8 July 2024)

* Dropped support for Ruby <2.7 ([#13](https://github.com/hausgold/grape-jwt-authentication/pull/13))

### 2.3.0 (16 January 2024)

* Implemented case-insensitive header value checks for Grape 2.0.0+
  compatibility, aligning with HTTP/2+ semantics (#11, #12)
* Moved the development dependencies from the gemspec to the Gemfile ([#10](https://github.com/hausgold/grape-jwt-authentication/pull/10))

### 2.2.0 (24 February 2023)

* Added support for Gem release automation

### 2.1.0 (18 January 2023)

* Bundler >= 2.3 is from now on required as minimal version ([#9](https://github.com/hausgold/grape-jwt-authentication/pull/9))
* Dropped support for Ruby < 2.5 ([#9](https://github.com/hausgold/grape-jwt-authentication/pull/9))
* Dropped support for Rails < 5.2 ([#9](https://github.com/hausgold/grape-jwt-authentication/pull/9))
* Updated all development/runtime gems to their latest
  Ruby 2.5 compatible version ([#9](https://github.com/hausgold/grape-jwt-authentication/pull/9))

### 2.0.4 (15 October 2021)

* Migrated to Github Actions
* Migrated to our own coverage reporting
* Added the code statistics to the test process

### 2.0.3 (12 May 2021)

* Pinned rspec-expectations to <= 3.9.2
* Removed the rspec-expectations pinning

### 2.0.2 (7 September 2020)

* Corrected some documentation glitches

### 2.0.1 (7 September 2020)

* Corrected a migration bug on the configuration which used the wrong namespace
  for `RsaPublicKey` (resulted in `uninitialized constant
  Grape::Jwt::Authentication::Configuration::RsaPublicKey`)

### 2.0.0 (7 September 2020)

* Extracted the JWT verification functionality into its own gem
  ([keyless](https://github.com/hausgold/keyless)) ([#6](https://github.com/hausgold/grape-jwt-authentication/pull/6))
  * This extraction allows users to use the JWT/RSA key handling without Grape
  * The API/configuration stays the same
* With the major update to 2.0 we dropped a lot of code which is now located at
  the Keyless gem:
  * `Grape::Jwt::Authentication::Jwt` was replace with `Keyless::Jwt`
  * `Grape::Jwt::Authentication::RsaPublicKey` was replace with `Keyless::RsaPublicKey`

### 1.3.0 (4 February 2020)

* Dropped support for EOL Ruby 2.3 (in addition to Grape)

### 1.2.0 (14 February 2019)

* Check the remote response on public key fetching ([#3](https://github.com/hausgold/grape-jwt-authentication/pull/3))
* Added support for Ruby 2.6
* Dropped support for EOL Ruby 2.2

### 1.1.0 (1 November 2018)

* Added the parsed and original token to the Rack environment ([#2](https://github.com/hausgold/grape-jwt-authentication/pull/2))
  * Two new helper methods are now available to access the JWT from an API spec

### 1.0.1 (23 November 2017)

* First public release of the gem

### 1.0.0 (23 November 2017)

* Yanked, published with the wrong account
