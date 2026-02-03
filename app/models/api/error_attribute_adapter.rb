# frozen_string_literal: true

module Api
  module ErrorAttributeAdapter
    def self.included(base)
      base.extend(ClassMethods)
      base.class_attribute(:csv_field_mappings)
      base.class_attribute(:csv_field_mappings_version)
    end

    NESTED_CSV_ATTRIBUTE_NAMES = {
      hesa_trainee_detail_attributes: "",
      placements_attributes: "",
      degrees_attributes: "",
    }.freeze

    NESTED_API_ATTRIBUTE_NAMES = {
      hesa_trainee_detail_attributes: "",
      degrees_attributes: "",
      trainee_disabilities_attributes: "disabilities",
    }.freeze

    module ClassMethods
      def attribute_mappings
        version = module_parent_name.demodulize

        if csv_field_mappings.blank? || csv_field_mappings_version != version
          self.csv_field_mappings_version = version
          self.csv_field_mappings = begin
            fields = YAML.load_file("BulkUpdate::AddTrainees::#{version}::ImportRows".constantize.fields_definition_path)
            fields.to_h do |field|
              [field["technical"].to_sym, field["field_name"]]
            end
          end
        end

        csv_field_mappings
      end

      def human_attribute_name(attr, options = {})
        if options[:base]&.record_source == Trainee::CSV_SOURCE
          attribute_mappings[attr.to_sym] || NESTED_CSV_ATTRIBUTE_NAMES[attr.to_sym]
        elsif (nested_api_attribute_name = NESTED_API_ATTRIBUTE_NAMES[attr.to_sym])
          nested_api_attribute_name
        else
          I18n.t("activemodel.attributes.#{model_name.i18n_key}.#{attr}", default: attr.to_s)
        end || super
      end
    end

    def errors
      model = self

      super.tap do |err|
        err.define_singleton_method(:add) do |attribute, type = :invalid, **options|
          translation_key = "activemodel.errors.models.#{model.class.name.underscore}.attributes.#{attribute}.#{model.record_source}.#{type}"

          record_source_type = if I18n.exists?(translation_key)
                                 :"#{model.record_source}.#{type}"
                               else
                                 type
                               end
          super(attribute, record_source_type, **options)
        end
      end
    end
  end
end
