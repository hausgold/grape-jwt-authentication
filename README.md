![grape-jwt-authentication](doc/assets/project.png)

[![Build Status](https://api.travis-ci.org/hausgold/grape-jwt-authentication.svg)](https://travis-ci.org/hausgold/grape-jwt-authentication)
[![Gem Version](https://badge.fury.io/rb/grape-jwt-authentication.svg)](https://badge.fury.io/rb/grape-jwt-authentication)
[![Maintainability](https://api.codeclimate.com/v1/badges/446f3eff18bebff9c174/maintainability)](https://codeclimate.com/github/hausgold/grape-jwt-authentication/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/446f3eff18bebff9c174/test_coverage)](https://codeclimate.com/github/hausgold/grape-jwt-authentication/test_coverage)

This gem is dedicated to easily integrate a JWT authentication to your
[Grape](https://github.com/ruby-grape/grape) API. The real authentication
functionality must be provided by the user and this makes this gem highy
flexible on the JWT verification level.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'grape-jwt-authentication'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install grape-jwt-authentication
```

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/hausgold/grape-jwt-authentication.
