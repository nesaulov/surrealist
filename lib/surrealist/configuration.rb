# frozen_string_literal: true

require_relative 'configuration/validator'
require_relative 'configuration/settings_helper'

module Surrealist
  # Surrealist's main configuration class.
  class Configuration
    include SettingsHelper
    extend Gem::Deprecate

    DEFAULT_NESTING_LEVEL = 666

    options :camelize,
            :include_root,
            :include_namespaces,
            :root,
            :namespace_nesting_level,
            :type_system

    alias camelize? camelize
    alias include_root? include_root
    alias include_namespaces? include_namespaces

    # Aliases for backward compatibility.
    alias namespaces_nesting_level namespace_nesting_level
    deprecate :namespaces_nesting_level, 'namespace_nesting_level', 2020, 1

    def initialize(**args)
      # Alias for backward compatibility.
      namespace_nesting_level = args[:namespace_nesting_level] || args[:namespaces_nesting_level]

      @camelize                 = args.fetch(:camelize, false)
      @include_root             = args.fetch(:include_root, false)
      @include_namespaces       = args.fetch(:include_namespaces, false)

      self.root = args.fetch(:root, nil)
      self.namespace_nesting_level = namespace_nesting_level
      self.type_system = args.fetch(:type_system, nil)

      super
    end

    def root=(value)
      set_option(
        :root,
        if value.is_a?(String)
          value.strip
        else
          value
        end,
      )
    end

    def namespace_nesting_level=(value)
      set_option(:namespace_nesting_level, value || DEFAULT_NESTING_LEVEL)
    end
    alias namespaces_nesting_level= namespace_nesting_level=
    deprecate :namespaces_nesting_level=, 'namespace_nesting_level=', 2020, 1

    def type_system=(value)
      set_option(
        :type_system,
        case value
        when nil then Surrealist::TypeSystems::Builtin # default
        when :builtin then Surrealist::TypeSystems::Builtin
        when :dry_types then Surrealist::TypeSystems::DryTypes
        else
          value
        end,
      )
    end

    def default?
      self == DEFAULT
    end

    def ==(other)
      settings == other.settings
    end

    def with_overrides(**overrides)
      return self if overrides.empty?

      # Alias for backward compatibility.
      if overrides.key?(:namespaces_nesting_level)
        overrides.merge!(namespace_nesting_level: overrides.delete(:namespaces_nesting_level))
      end

      self.class.new(settings.merge(overrides))
    end

    def settings
      {
        camelize: camelize,
        include_root: include_root,
        include_namespaces: include_namespaces,
        root: root,
        namespace_nesting_level: namespace_nesting_level,
        type_system: type_system,
      }
    end
  end

  Configuration::DEFAULT = Configuration.new.freeze
end
