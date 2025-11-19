# frozen_string_literal: true

require 'singleton'

module ReferenceData
  class Loader
    include Singleton

    attr_reader :types

  private

    def initialize
      load_all
    end

    def load_all
      @types = Dir[Rails.root.join("config", "reference_data", "*.yml")].map do |file_path|
        type_data = YAML.load_file(file_path)
        ReferenceData::Type.from_yaml(
          metadata: type_data["metadata"].with_indifferent_access,
          data: type_data["data"],
        )
      end
    end
  end
end
