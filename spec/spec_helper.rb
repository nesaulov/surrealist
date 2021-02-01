# frozen_string_literal: true

require 'coveralls'
require 'simplecov'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter,
  ],
)
Coveralls.wear! { add_filter 'spec' }

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'dry-struct'
require 'dry-types'
require 'pry'
require 'rom'
require 'rom-repository'
require_relative '../lib/surrealist'

require_relative 'support/shared_contexts/parameters_contexts'
require_relative 'support/shared_examples/hash_examples'
require_relative 'orms/active_record/models'
require_relative 'orms/sequel/models'

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.order = 'random'
end

def ruby25
  ::RUBY_VERSION =~ /2.5/
end

module Types
  include Dry.Types
end

srand RSpec.configuration.seed
