# frozen_string_literal: true

require_relative 'builder'
require_relative 'schema_definer'

module Surrealist
  module ClassMethods
    def schema(&_block)
      SchemaDefiner.call(self, yield)
    end
  end
end
