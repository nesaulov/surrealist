# frozen_string_literal: true

require_relative 'schemeson/class_methods'
require_relative 'schemeson/instance_methods'
require 'multi_json'

module Schemeson
  class UnknownSchemaError < StandardError; end

  class << self
    def included(base)
      base.extend(Schemeson::ClassMethods)
      base.include(Schemeson::InstanceMethods)
    end

    def serialize(zelf)
      # TODO: rename
      methods = zelf.__schemeson_methods rescue nil

      if methods.nil?
        raise Schemeson::UnknownSchemaError, "Can't serialize #{zelf.class} - no schema was provided."
      end

      hash = methods.each_with_object({}) { |method, hash| hash[method] = zelf.send(method) }

      ::MultiJson.dump(hash)
    end
  end
end
