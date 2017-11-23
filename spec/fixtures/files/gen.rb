# frozen_string_literal: true

require 'openssl'
require 'pathname'

root = Pathname.new(__dir__)

private_key_path = root.join('rsa1')
public_key_path = root.join('rsa1.pub')

rsa_key = OpenSSL::PKey::RSA.new(2048)

File.write(private_key_path, rsa_key.to_pem)
File.write(public_key_path, rsa_key.public_key.to_pem)
