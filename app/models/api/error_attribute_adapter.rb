# frozen_string_literal: true

module Api
  module ErrorAttributeAdapter
    def self.included(base)
      base.extend(ClassMethods)
      base.class_attribute(:csv_field_mappings)
    end

    NESTED_CSV_ATTRIBUTE_NAMES = {
      hesa_trainee_detail_attributes: "",
      placement_attributes: "",
      degree_attributes: "",
    }.freeze

    NESTED_API_ATTRIBUTE_NAMES = {
      hesa_trainee_detail_attributes: "",
    }.freeze

    module ClassMethods
      def attribute_mappings
        self.csv_field_mappings ||= begin
          fields = YAML.load_file(CsvFields::View::FIELD_DEFINITION_PATH)
          fields.to_h do |field|
            [field["technical"].to_sym, field["field_name"]]
          end
        end
      end

      def human_attribute_name(attr, options = {})
        if options[:base]&.record_source == Trainee::CSV_SOURCE
          attribute_mappings[attr.to_sym] || NESTED_CSV_ATTRIBUTE_NAMES[attr.to_sym]
        else
          NESTED_API_ATTRIBUTE_NAMES[attr.to_sym] || attr.to_s
        end || super
      end
    end
  end
end
