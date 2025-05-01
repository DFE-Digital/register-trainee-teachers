# frozen_string_literal: true

module Api
  module ErrorAttributeAdapter
    def self.included(base)
      base.extend(ClassMethods)
      base.class_attribute(:csv_field_mappings)
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

    NO_ATTRIBUTE_NAMES = {
      course_subject_two: %i[api.duplicate csv.duplicate],
      course_subject_three: %i[api.duplicate csv.duplicate],
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

        err.define_singleton_method(:full_messages) do
          errors.map do |error|
            mapped_error = NO_ATTRIBUTE_NAMES[error.attribute]

            if mapped_error.present? && error.type.in?(mapped_error)
              error.message
            else
              error.full_message
            end
          end
        end
      end
    end
  end
end
