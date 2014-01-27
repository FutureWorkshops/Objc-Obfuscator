Gem::Specification.new do |s|
  s.name        = 'objc-obfuscator'
  s.version     = '0.2.3'
  s.date        = '2014-01-23'
  s.summary     = "A simple obfuscator that encrypts strings in source files"
  s.description = "A simple obfuscator that encrypts strings in source files"
  s.authors     = ["Fabio Gallonetto"]
  s.email       = 'fabio@futureworkshops.com'
  s.files       = ["lib/obfuscator.rb"]
  s.homepage    = 'http://github.com/FutureWorkshops/Obfuscator-ruby'
  s.license     = 'BSD'

  s.files       = `git ls-files -- {bin,lib}/*`.split("\n")

  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']

  s.add_runtime_dependency 'encryptor', '~> 1.3.0'
  s.add_runtime_dependency 'thor', '~> 0.18.1'
  s.add_runtime_dependency 'xcodeproj', '~> 0.14.1'

  s.add_development_dependency 'rspec', '~> 2.13.0'
  s.add_development_dependency 'rake', '~> 10.0.3'
end
