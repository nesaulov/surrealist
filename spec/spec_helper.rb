# frozen_string_literal: true

require 'coveralls'

SimpleCov.start do
  filters.clear

  add_filter do |src|
    src.filename =~ /^#{SimpleCov.root}\/lib/
  end
end

Coveralls.wear!

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'surrealist'

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.order = 'random'
end

srand RSpec.configuration.seed
