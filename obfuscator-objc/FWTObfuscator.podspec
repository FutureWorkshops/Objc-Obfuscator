Pod::Spec.new do |s|
  s.name         = "FWTObfuscator"
  s.platform     = :ios
  s.version      = "0.1.0"
  s.summary      = "ObjC library that supports objc-obfuscator gem"
  s.description  = <<-DESC
                   A simple obfuscator that encrypts strings in source files.
                   DESC
  s.homepage     = "http://github.com/FutureWorkshops/Obfuscator-ruby"
  s.license      = 'BSD'
  s.author       = { "fabio@futureworkshops.com" => "Fabio Gallonetto" }
  s.source       = { :git => "https://github.com/FutureWorkshops/FWTObfuscator.git", :tag => s.version.to_s }

  s.requires_arc = true

  s.source_files = "*.{h,m}"
  s.frameworks = 'Security'
  s.public_header_files = '*.h'
  s.private_header_files = 'FWTObfuscator+Private.h'
  
end
