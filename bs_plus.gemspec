# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bs_plus/version'

Gem::Specification.new do |spec|
  spec.name          = 'bs_plus'
  spec.version       = BsPlus::VERSION
  spec.authors       = ['Leo']
  spec.email         = ['leonid.inbox@gmail.com']
  spec.summary       = %q{This should use your automate plan of browserstack and do screenshots}
  spec.description   = %q{This should use your automate plan of browserstack and do screenshots}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']


  spec.add_dependency 'highline', '>=1.6.21'
  spec.add_dependency 'activesupport', '>=4.2.0'
  spec.add_dependency 'retryable', '>=1.3.5'
  spec.add_dependency 'parallel', '>=1.3.0'
  spec.add_dependency 'thor', '>=0.19.1'
  spec.add_dependency 'rest-client', '>=1.7.2'
  spec.add_dependency 'hashie', '>3.1.0'
  spec.add_dependency 'launchy', '>=2.4.0'
  spec.add_dependency 'selenium-webdriver', '>=2.44.0'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'pry-rescue'
  spec.add_development_dependency 'pry'
end
