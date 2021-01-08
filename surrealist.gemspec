# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'surrealist/version'

Gem::Specification.new do |spec|
  spec.name          = 'surrealist'
  spec.version       = Surrealist::VERSION
  spec.authors       = ['Nikita Esaulov']
  spec.email         = ['billikota@gmail.com']

  spec.summary       = 'A gem that provides DSL for serialization of plain old Ruby objects to JSON ' \
                       'in a declarative style.'
  spec.description   = 'A gem that provides DSL for serialization of plain old Ruby objects to JSON ' \
                       'in a declarative style by defining a `schema`. ' \
                       'It also provides a trivial type checking in the runtime before serialization.'
  spec.homepage      = 'https://github.com/nesaulov/surrealist'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.4.0'

  spec.add_runtime_dependency 'oj', '~> 3.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'pry', '~> 0.12'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.8'
  spec.add_development_dependency 'rubocop', '~> 1.8'
end
