# frozen_string_literal: true

class Serializer
  def self.for(model:, version:)
    module_name = module_name_for(model)
    constant_module = Object.const_get(module_name)
    class_name = class_name_for(version)
    if constant_module.const_defined?(class_name)
      constant_module.const_get(class_name)
    else
      raise(NotImplementedError, "#{module_name}::#{class_name}")
    end
  end

  def self.class_name_for(version)
    version.gsub(".", "").camelize
  end

  def self.module_name_for(model)
    "#{model}_#{module_name_suffix}".camelize
  end

  def self.module_name_suffix = "Serializer"
end
