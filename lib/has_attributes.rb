# frozen_string_literal: true

require_relative "has_attributes/version"
require "active_support/concern"
require "global_id_serialiser"

module HasAttributes
  extend ActiveSupport::Concern
  class Error < StandardError; end

  class_methods do
    def has_attribute name, cast_type = :string, field_name: "data", **options
      typecaster = cast_type.nil? ? nil : ActiveRecord::Type.lookup(cast_type)
      typecast_value = ->(value) { typecaster.nil? ? value : typecaster.cast(value) }
      define_attribute_method name
      if cast_type != :boolean
        define_method(name.to_sym) { typecast_value.call(send(field_name.to_sym)[name.to_s]) || options[:default] }
      else
        define_method(name.to_sym) do
          value = typecast_value.call(send(field_name.to_sym)[name.to_s])
          [true, false].include?(value) ? value : options[:default]
        end
        alias_method :"#{name}?", name.to_sym
      end
      define_method(:"#{name}=") do |value|
        attribute_will_change! name
        send(field_name.to_sym)[name.to_s] = typecast_value.call(value)
      end
    end
  end
end
