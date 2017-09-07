# frozen_string_literal: true

require_relative 'surrealist/class_methods'
require_relative 'surrealist/instance_methods'
require_relative 'surrealist/extensions/boolean'
require 'multi_json'

module Surrealist
  # Error class for classes without defined #schema
  class UnknownSchemaError < RuntimeError; end

  # Error class for classes with #schema defined not as a hash
  class InvalidSchemaError < RuntimeError; end

  # Error class for NoMethodError
  class UndefinedMethodError < RuntimeError; end

  class << self
    def included(base)
      base.extend(Surrealist::ClassMethods)
      base.include(Surrealist::InstanceMethods)
    end

    def surrealize(zelf)
      schema = zelf.__surrealist_schema rescue nil

      if schema.nil?
        raise Surrealist::UnknownSchemaError, "Can't serialize #{zelf.class} - no schema was provided."
      end

      ::MultiJson.dump(Builder.call(schema, zelf))
    end
  end
end
