# frozen_string_literal: true

module DegreeSerializer
  def self.for(version)
    Object.const_get("DegreeSerializer::#{class_name_for(version)}")
  end

  def self.class_name_for(version)
    version.gsub(".", "").camelize
  end
end
