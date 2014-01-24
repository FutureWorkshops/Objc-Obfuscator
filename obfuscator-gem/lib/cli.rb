require 'thor'
require 'objc-obfuscator/obfuscator'
require 'objc-obfuscator/integrator'


module Objc_Obfuscator
  class CLI < Thor

    register Objc_Obfuscator::Obfuscator, 'obfuscate', 'Obfuscate a source file'
    register Objc_Obfuscator::Integrator, 'integrate', 'Integrate Obfuscator with an Xcode project'
  end
end
