require 'encryptor'
require 'base64'

module Objc_Obfuscator
  class StringEncryptor
    attr_reader :last_iv
    attr_reader :last_salt
    attr_accessor :key

    class EncryptorError < StandardError
    
    end

    def initialize(key)
      @key = key
    end

    def encrypt(unencrypted_string)
      raise EncryptorError::Error "FATAL: Can't encrypt with an empty key" if key.empty?
      return '' if unencrypted_string.empty?
      salt = Time.now.to_i.to_s
      iv = OpenSSL::Cipher::Cipher.new('aes-256-cbc').random_iv
      Encryptor.default_options.merge!(:key => key , :iv => iv, :salt => salt)
      
      encrypted_string = Base64.strict_encode64 unencrypted_string.encrypt
      @last_iv = Base64.strict_encode64 iv
      @last_salt = Base64.strict_encode64 salt

      "#{encrypted_string}-#{last_iv}-#{last_salt}"

    end
  end
end
