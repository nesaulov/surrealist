# frozen_string_literal: true

module Surrealist
  class SchemaDefiner
    def self.call(klass, hash)
      raise Surrealist::InvalidSchemaError, 'Schema should be defined as a hash' unless hash.is_a?(Hash)

      klass.instance_eval do
        define_method '__surrealist_schema' do
          hash
        end
      end
    end
  end
end
