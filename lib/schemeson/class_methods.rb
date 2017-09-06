# frozen_string_literal: true

require_relative 'builder'

module Schemeson
  module ClassMethods
    def builds(methods)
      Builder.call(self, methods)
    end
  end
end
