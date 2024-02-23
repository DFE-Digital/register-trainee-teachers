# frozen_string_literal: true

class Serializer
  def self.for(model:, version:)
    Object.const_get("#{module_name_for(model)}::#{class_name_for(version)}")
  end

  def self.class_name_for(version)
    version.gsub(".", "").camelize
  end

  def self.module_name_for(model)
    "#{model}Serializer".camelize
  end
end
