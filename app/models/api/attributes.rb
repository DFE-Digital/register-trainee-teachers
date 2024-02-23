# frozen_string_literal: true

module Api
  class Attributes
    def self.for(model:, version:)
      Object.const_get("Api::#{module_name_for(model)}::#{class_name_for(version)}")
    end

    def self.class_name_for(version)
      version.gsub(".", "").camelize
    end

    def self.module_name_for(model)
      "#{model}Attributes".camelize
    end
  end
end
