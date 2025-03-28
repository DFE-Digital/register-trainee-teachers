# frozen_string_literal: true

module Api
  module ErrorAttributeAdapter
    def self.included(base)
      base.attr_accessor(:record_source)
      base.extend(ClassMethods)
      base.class_attribute(:csv_field_mappings)
    end

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
        if options[:base]&.record_source == :csv && attribute_mappings.key?(attr.to_sym)
          attribute_mappings[attr.to_sym]
        end || super
      end
    end
  end
end
