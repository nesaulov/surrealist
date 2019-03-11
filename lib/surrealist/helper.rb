# frozen_string_literal: true

module Surrealist
  # A generic helper.
  module Helper
    # Determines if the class uses the Surrealist mixin.
    #
    # @param [Class] klass a class to be checked.
    #
    # @return [Boolean] if Surrealist is included in class.
    def self.surrealist?(klass)
      klass < Surrealist || klass < Surrealist::Serializer
    end

    def self.collection?(object)
      # 4.2 AR relation object did not include Enumerable (it defined
      # all necessary method through ActiveRecord::Delegation module),
      # so we need to explicitly check for this
      return false if object.is_a?(Struct)

      object.is_a?(Enumerable) && !object.instance_of?(Hash) || ar_relation?(object)
    end

    def self.ar_relation?(object)
      defined?(ActiveRecord) && object.is_a?(ActiveRecord::Relation)
    end
    private_class_method :ar_relation?
  end
end
