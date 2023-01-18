# frozen_string_literal: true

# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
(directories %w[lib spec]).select do |d|
  if Dir.exist?(d)
    d
  else
    UI.warning("Directory #{d} does not exist")
  end
end

## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"

# NOTE: The cmd option is now required due to the increasing number of ways
#       rspec may be run, below are examples of the most common uses.
#  * bundler: 'bundle exec rspec'
#  * bundler binstubs: 'bin/rspec'
#  * spring: 'bin/rspec' (This will use spring if running and you have
#                          installed the spring binstubs per the docs)
#  * zeus: 'zeus rspec' (requires the server to be started separately)
#  * 'just' rspec: 'rspec'

guard :rspec, cmd: 'bundle exec rspec' do
  watch('spec/spec_helper.rb') { 'spec' }
  watch(%r{^lib/grape/jwt/authentication.rb}) { 'spec' }
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/grape/jwt/authentication/([^\\]+)\.rb$}) do |m|
    "spec/grape/jwt/authentication/#{m[1]}_spec.rb"
  end
  watch(%r{^lib/grape/jwt/authentication/([^\\]+)/(.*)\.rb$}) do |m|
    "spec/grape/jwt/authentication/#{m[1]}/#{m[2]}_spec.rb"
  end
end
