# frozen_string_literal: true

require_relative 'schemeson/class_methods'
require_relative 'schemeson/instance_methods'

module Schemeson
  class << self
    def included(base_class)
      base_class.extend(Schemeson::ClassMethods)
      base_class.include(Schemeson::InstanceMethods)
    end

    def serialize(zelf)
      # TODO: rename & rescue
      methods = zelf.__schemeson_methods
      methods.each_with_object({}) do |method, hash|
        hash[method] = zelf.send(method)
      end
    end
  end
end
