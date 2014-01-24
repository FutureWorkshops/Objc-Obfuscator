require 'objc-obfuscator/stringencryptor'
require 'encryptor'
require 'tmpdir'


describe StringEncryptor do
  
  before do 
    @encryptor = StringEncryptor.new 'mySecretKey'
  end

  it "encrypts a string into a concatenated base64 format" do
    unencrypted_string = 'MySecretSecretString'
    encrypted_string = @encryptor.encrypt unencrypted_string
    components = encrypted_string.split '-'
    encrypted_payload = components[0]
    iv = components[1]
    salt = components[2]
    @encryptor.last_iv.should eq(iv)
    @encryptor.last_salt.should eq(salt)
    
    Encryptor.decrypt(:value => encrypted_payload, :key => 'mySecretKey', :iv => iv, :salt => salt).should eq(unencrypted_string)
  end

  it "doesn't fail with empty string" do
    @encryptor.encrypt ''
  end

end
