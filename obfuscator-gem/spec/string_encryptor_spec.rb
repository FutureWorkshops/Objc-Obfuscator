require 'objc-obfuscator/stringencryptor'
require 'encryptor'
require 'base64'


describe "StringEncryptor" do
  
  before do 
    @encryptor = Objc_Obfuscator::StringEncryptor.new 'mySecretKey'
  end

  it "encrypts a string into a concatenated base64 format (enc-iv-salt)" do
    unencrypted_string = 'MySecretSecretString'
    encrypted_string = @encryptor.encrypt unencrypted_string
    components = encrypted_string.split '-'
    encrypted_payload = Base64.strict_decode64 components[0]
    iv = components[1]
    salt = components[2]
    @encryptor.last_iv.should eq(iv)
    @encryptor.last_salt.should eq(salt)
    iv = Base64.strict_decode64 iv
    salt = Base64.strict_decode64 salt

    Encryptor.decrypt(:value => encrypted_payload, :key => 'mySecretKey', :iv => iv, :salt => salt).should eq(unencrypted_string)
  end

  it "fails with empty key" do
    @encryptor.key = ''
    expect { @encryptor.encrypt 'mystring' }.to raise_error
  end

  it "doesn't fail with empty string" do
    @encryptor.encrypt('').should eq('')
  end

end
