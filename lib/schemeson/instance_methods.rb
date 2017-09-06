# frozen_string_literal: true

module Schemeson
  module InstanceMethods
    def serialize
      Schemeson.serialize(self)
    end
  end
end
