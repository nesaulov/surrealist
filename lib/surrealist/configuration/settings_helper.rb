# frozen_string_literal: true

module Surrealist
  class Configuration
    # A set of helpers used in Configuration.
    # @api private
    module SettingsHelper
      def self.included(base)
        base.extend(ClassMethods)
        base.include(InstanceMethods)
      end

      # A convenient way of defining methods for options. Options must be validated every time
      # when set after an instance of Configuration is initialized.
      module ClassMethods
        def options(*option_names)
          option_names.each do |option_name|
            attr_reader(option_name)
            define_method(:"#{option_name}=") { |value| set_option(option_name, value) }
          end
        end
      end

      # Helper methods for ensuring that validations happen every time an option is set.
      module InstanceMethods
        def initialize(*)
          Validator.new(self).call
          @__initialized__ = true
        end

        def initialized?
          @__initialized__
        end

        def set_option(option_name, value)
          instance_variable_set(:"@#{option_name}", value)
          Validator.new(self).call if initialized?
        end
      end
    end
  end
end
