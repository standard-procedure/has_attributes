# frozen_string_literal: true

require_relative "has_attributes/version"
require "active_support/concern"
require "active_support/core_ext/string/inflections"
require "global_id_serialiser"

module HasAttributes
  extend ActiveSupport::Concern
  class Error < StandardError; end

  class_methods do
    def has_attribute name, cast_type = :string, field_name: :data, **options
      field_name = field_name.to_sym
      name = name.to_sym
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

    def has_model name, class_name = nil, field_name: :data, **options
      name = name.to_sym
      id_attribute = :"#{name}_id"
      has_attribute id_attribute, field_name:, **options
      validate :"#{name}_class_name", if: -> { send(name).present? } if class_name.present?

      define_method(name.to_sym) do
        model_id = send id_attribute
        model_id.nil? ? nil : GlobalID::Locator.locate(model_id.sub("modelid-", ""))
      rescue ActiveRecord::RecordNotFound
        nil
      end

      define_method(:"#{name}=") do |model|
        model_id = model.nil? ? nil : "modelid-#{model.to_global_id}"
        send :"#{id_attribute}=", model_id
      end

      define_method :"#{name}_class_name" do
        errors.add name, :invalid unless send(name).is_a?(class_name.constantize)
      end
    end
  end
end
