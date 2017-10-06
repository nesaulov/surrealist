# frozen_string_literal: true

require 'coveralls'

Coveralls.wear! do
  add_filter '/spec/'
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'surrealist'

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.order = 'random'
end

srand RSpec.configuration.seed
