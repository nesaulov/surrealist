lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'schemeson/version'

Gem::Specification.new do |spec|
  spec.name          = 'schemeson'
  spec.version       = Schemeson::VERSION
  spec.authors       = ['Nikita Esaulov']
  spec.email         = ['billikota@gmail.com']

  spec.summary       = "Convert object's schema to Jbuilder object"
  spec.description   = "Convert object's schema to Jbuilder object"
  spec.homepage      = 'https://github.com/nesaulov/schemeson'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'jbuilder', '~> 2.5'
  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rspec', '~> 3.6.0'
end
