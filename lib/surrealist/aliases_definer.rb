module Surrealist
  class AliasesDefiner
    ALIASES_TYPE_ERROR = 'Aliases should be defined as a hash'.freeze

    # Defines an instance variable for storing schema aliases.
    #
    # @param [Object] klass class of the object that has json schema defining
    #
    # @param [Hash] aliases hash of the aliases in format '{alias: :original}'
    #
    # @return [Hash] +@__surrealist_aliases+ variable that stores the aliases of schema
    def self.call(klass, aliases)
      raise Surrealist::InvalidAliasesError, ALIASES_TYPE_ERROR unless aliases.is_a?(Hash)

      klass.instance_variable_set(Surrealist::ALIASES_INSTANCE_VARIABLE, aliases)
    end
  end
end