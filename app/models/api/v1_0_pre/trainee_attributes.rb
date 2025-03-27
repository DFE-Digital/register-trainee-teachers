# frozen_string_literal: true

module Api
  module V10Pre
    class TraineeAttributes < Api::V01::TraineeAttributes
      attr_accessor :context
      class_attribute :csv_field_mappings

      def self.attribute_mappings
        self.csv_field_mappings ||= begin
          fields = YAML.load_file(CsvFields::View::FIELD_DEFINITION_PATH)
          fields.to_h do |field|
            [field["technical"].to_sym, field["field_name"]]
          end
        end
      end

      def self.human_attribute_name(attr, _options = {})
        require 'pry'; binding.pry
        if context == :csv && self.attribute_mappings.key?(attr.to_sym)
          self.attribute_mappings[attr.to_sym]
        end || super
      end
    end
  end
end
