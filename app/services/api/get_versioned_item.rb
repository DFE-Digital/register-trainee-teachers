# frozen_string_literal: true

module Api
  class GetVersionedItem
    def self.for_service(model:, version:)
      self.for(model: model, version: version, item_type: :service)
    end

    def self.for_attributes(model:, version:)
      self.for(model: model, version: version, item_type: :attributes)
    end

    def self.for_serializer(model:, version:)
      self.for(model: model, version: version, item_type: :serializer)
    end

    def self.for(model:, version:, item_type:)
      class_name = "Api::#{module_version(version)}::#{class_name_for(model, item_type)}"

      if Object.const_defined?(class_name) && Settings.api.allowed_versions.include?(version)
        Object.const_get(class_name)
      else
        raise(NotImplementedError, class_name)
      end
    end

    def self.module_version(version)
      version.gsub(".", "").camelize
    end

    def self.class_name_for(model, item_type)
      if item_type == :service
        if model == :map_hesa_attributes
          "HesaMapper::Attributes"
        elsif %i[degree placement].include?(model)
          "HesaMapper::#{model.to_s.camelize}Attributes".camelize
        else
          "#{model}_#{item_type.capitalize}".camelize
        end
      else
        "#{model}_#{item_type.capitalize}".camelize
      end
    end
  end
end
