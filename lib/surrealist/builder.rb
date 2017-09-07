# frozen_string_literal: true

module Surrealist
  class Builder
    def self.call(schema, instance)
      schema.each do |key, value|
        if value.is_a? Hash
          call(value, instance)
        else
          val = instance.send(key)

          if val.is_a? value
            schema[key] = val
          else
            raise TypeError, "Wrong type for key `#{key}`. Expected #{value}, got #{val.class}"
          end
        end
      end
    end
  end
end
