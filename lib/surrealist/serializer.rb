# frozen_string_literal: true

module Surrealist
  # Abstract class to be inherited from
  class Serializer
    extend Surrealist::ClassMethods

    attr_reader :object

    def initialize(object)
      @object = object
    end

    def surrealize(**args)
      if object.respond_to?(:each)
        Surrealist.surrealize_collection(object, args)
      else
        Surrealist.surrealize(instance: self, **args)
      end
    end

    def build_schema(**args)
      Surrealist.build_schema(instance: self, **args)
    end

    private

    def method_missing(method, *args, &block)
      object.public_send(method, *args, &block) || super
    end

    def respond_to_missing?(method, include_private = false)
      object.respond_to?(method) || super
    end
  end
end
