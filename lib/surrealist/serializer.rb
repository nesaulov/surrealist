# frozen_string_literal: true

module Surrealist
  class Serializer
    extend Surrealist::ClassMethods
    include Surrealist::InstanceMethods

    attr_reader :object

    def initialize(object)
      @object = object
    end

    def surrealize(**args)
      if object.respond_to?(:each)
        # binding.pry
        Surrealist.surrealize_collection(object, args)
      else
        # binding.pry
        # object.surrealize(args)
      end
    end

    private

    def method_missing(method, *args, &block)
      object.send(method, *args, &block)
    end

    def respond_to_missing?(method, include_private = false)
      super
    end
  end
end
