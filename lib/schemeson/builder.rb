# frozen_string_literal: true

module Schemeson
  class Builder
    def self.call(klass, methods)
      new(klass).build_schema(methods)
    end

    def initialize(klass)
      @klass = klass
    end

    def build_schema(buildable_methods)
      klass.instance_eval do
        define_method '__schemeson_methods' do
          buildable_methods
        end
      end
    end

    private

    attr_reader :klass
  end
end
