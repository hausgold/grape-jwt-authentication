### 2.0.3

* Pinned rspec-expectations to <= 3.9.2
* Removed the rspec-expectations pinning

### 2.0.2

* Corrected some documentation glitches

### 2.0.1

* Corrected a migration bug on the configuration which used the wrong namespace
  for `RsaPublicKey` (resulted in `uninitialized constant
  Grape::Jwt::Authentication::Configuration::RsaPublicKey`)

### 2.0.0

* Extracted the JWT verification functionality into its own gem
  ([keyless](https://github.com/hausgold/keyless)) (#6)
  * This extraction allows users to use the JWT/RSA key handling without Grape
  * The API/configuration stays the same
* With the major update to 2.0 we dropped a lot of code which is now located at
  the Keyless gem:
  * `Grape::Jwt::Authentication::Jwt` was replace with `Keyless::Jwt`
  * `Grape::Jwt::Authentication::RsaPublicKey` was replace with `Keyless::RsaPublicKey`

### 1.3.0

* Dropped support for EOL Ruby 2.3 (in addition to Grape)

### 1.2.0

* Check the remote response on public key fetching (#3)
* Added support for Ruby 2.6
* Dropped support for EOL Ruby 2.2

### 1.1.0

* Added the parsed and original token to the Rack environment (#2)
  * Two new helper methods are now available to access the JWT from an API spec

### 1.0.1

* First public release of the gem

### 1.0.0

* Yanked, published with the wrong account
