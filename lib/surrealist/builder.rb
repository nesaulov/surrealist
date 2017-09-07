# frozen_string_literal: true

module Surrealist
  # A class that builds a hash from the schema and type-checks the values.
  class Builder
    # A method that goes recursively through the schema hash, defines the values and type-checks them.
    #
    # @param [Hash] schema the schema defined in the object's class.
    #
    # @param [Object] instance the instance of the object which methods from the schema are called on.
    #
    # @raise +Surrealist::InvalidTypeError+ if type-check failed at some point.
    #
    # @raise +Surrealist::UndefinedMethodError+ if a key defined in the schema
    #   does not have a corresponding method on the object.
    #
    # @return [Hash] a hash that will be dumped into JSON.
    def self.call(schema, instance)
      schema.each do |key, value|
        if value.is_a? Hash
          call(value, instance)
        else
          val = instance.send(key)

          if val.is_a? value
            schema[key] = val
          else
            raise Surrealist::InvalidTypeError,
                  "Wrong type for key `#{key}`. Expected #{value}, got #{val.class}."
          end
        end
      end
    rescue NoMethodError => e
      raise Surrealist::UndefinedMethodError,
            "#{e.message}. You have probably defined a key " \
            "in the schema that doesn't have a corresponding method."
    end
  end
end
