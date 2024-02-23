# frozen_string_literal: true

module Api
  module TraineeAttributes
    def self.for(version)
      Object.const_get("Api::TraineeAttributes::#{class_name_for(version)}")
    end

    def self.class_name_for(version)
      version.gsub(".", "").camelize
    end
  end
end
