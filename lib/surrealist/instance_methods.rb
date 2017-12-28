# frozen_string_literal: true

module Surrealist
  # Instance methods that are included to the object's class
  module InstanceMethods
    # Dumps the object's methods corresponding to the schema
    # provided in the object's class and type-checks the values.
    #
    # @param [Boolean] camelize optional argument for converting hash to camelBack.
    # @param [Boolean] include_root optional argument for having the root key of the resulting hash
    #   as instance's class name.
    # @param [Boolean] include_namespaces optional argument for having root key as a nested hash of
    #   instance's namespaces. Animal::Cat.new.surrealize -> (animal: { cat: { weight: '3 kilos' } })
    # @param [String] root optional argument for using a specified root key for the hash
    # @param [Integer] namespaces_nesting_level level of namespaces nesting.
    #
    # @return [String] a json-formatted string corresponding to the schema
    #   provided in the object's class. Values will be taken from the return values
    #   of appropriate methods from the object.
    #
    # @raise +Surrealist::UnknownSchemaError+ if no schema was provided in the object's class.
    #
    # @raise +Surrealist::InvalidTypeError+ if type-check failed at some point.
    #
    # @raise +Surrealist::UndefinedMethodError+ if a key defined in the schema
    #   does not have a corresponding method on the object.
    #
    # @example Define a schema and surrealize the object
    #   class User
    #     include Surrealist
    #
    #     json_schema do
    #       {
    #         name: String,
    #         age: Integer,
    #       }
    #     end
    #
    #     def name
    #       'Nikita'
    #     end
    #
    #     def age
    #       23
    #     end
    #   end
    #
    #   User.new.surrealize
    #   # => "{\"name\":\"Nikita\",\"age\":23}"
    #   # For more examples see README
    def surrealize(camelize: false, include_root: false, include_namespaces: false, root: nil, namespaces_nesting_level: DEFAULT_NESTING_LEVEL) # rubocop:disable Metrics/LineLength
      if self.class.instance_variable_get('@__wrap_surrealist')
        serializer = self.class.instance_variable_get('@__surrealist_serializer')
        return serializer.new(self).surrealize(
          root:                     root,
          camelize:                 camelize,
          include_root:             include_root,
          include_namespaces:       include_namespaces,
          namespaces_nesting_level: namespaces_nesting_level,
        )
      end

      JSON.dump(
        build_schema(
          camelize: camelize,
          include_root: include_root,
          include_namespaces: include_namespaces,
          root: root,
          namespaces_nesting_level: namespaces_nesting_level,
        ),
      )
    end

    # Invokes +Surrealist+'s class method +build_schema+
    def build_schema(camelize: false, include_root: false, include_namespaces: false, root: nil, namespaces_nesting_level: DEFAULT_NESTING_LEVEL) # rubocop:disable Metrics/LineLength
      carrier = Surrealist::Carrier.call(
        camelize: camelize,
        include_namespaces: include_namespaces,
        include_root: include_root,
        root: root,
        namespaces_nesting_level: namespaces_nesting_level,
      )

      Surrealist.build_schema(instance: self, carrier: carrier)
    end
  end
end
