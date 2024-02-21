# frozen_string_literal: true

module Api
  module DegreeAttributes
    def self.for(version)
      Object.const_get("Api::DegreeAttributes::#{class_name_for(version)}")
    end

    def self.class_name_for(version)
      version.gsub(".", "").camelize
    end
  end
end
