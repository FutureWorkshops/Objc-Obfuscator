require 'objc-obfuscator/integrator'
require 'fileutils'

describe "StringEncryptor" do
  include ObjC_Obfuscator::Integrator

   # before do 
   #   @encryptor = Objc_Obfuscator::StringEncryptor.new 'mySecretKey'
   # end

  it "integrates the encryptor with xcode" do
    Dir.mktmpdir do |dir|
      FileUtils.cp_r 'spec/support/sample_project', dir
      project_path = File.join dir, 'sample_project', 'TestProject', 'TestProject.xcodeproj'
      podfile_path = File.join dir, 'sample_project', 'Podfile'
    end
  end
