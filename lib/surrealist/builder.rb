# frozen_string_literal: true

module Surrealist
  class Builder
    # TODO: refactor me maybe
    def self.call(schema, instance)
      schema.each do |key, value|
        if value.is_a? Hash
          call(value, instance)
        else
          val = instance.send(key)

          if val.is_a? value
            schema[key] = val
          else
            raise TypeError, "Wrong type for key `#{key}`. Expected #{value}, got #{val.class}."
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
