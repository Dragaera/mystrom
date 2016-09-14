# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mystrom/version'

Gem::Specification.new do |spec|
  spec.name          = 'mystrom'
  spec.version       = MyStrom::VERSION
  spec.authors       = ['Michael Senn']
  spec.email         = ['michael@morrolan.ch']

  spec.summary       = %q{Tiny interface to HTTP API of MyStrom WLAN switches}
  spec.homepage      = "https://bitbucket.org/dragaera/mystrom"
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'yard'

  spec.add_runtime_dependency 'httparty'
end
