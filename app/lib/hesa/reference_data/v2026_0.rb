# frozen_string_literal: true

module Hesa
  module ReferenceData
    class V20260 < V20250
      TYPES = {
        country: ::ReferenceData::COUNTRIES,
        course_age_range: ::ReferenceData::COURSE_AGE_RANGES,
        course_subject: ::ReferenceData::COURSE_SUBJECTS,
        degree_subject: ::ReferenceData::DEGREE_SUBJECTS,
        degree_grade: ::ReferenceData::DEGREE_GRADES,
        degree_type: ::ReferenceData::DEGREE_TYPES,
        disability: ::ReferenceData::DISABILITIES,
        ethnicity: ::ReferenceData::ETHNICITIES,
        fund_code: ::ReferenceData::FUND_CODES,
        funding_method: ::ReferenceData::FUNDING_METHODS,
        institution: ::ReferenceData::INSTITUTIONS,
        itt_aim: ::ReferenceData::ITT_AIMS,
        nationality: ::ReferenceData::NATIONALITIES,
        itt_qualification_aim: ::ReferenceData::ITT_QUALIFICATION_AIMS,
        sex: ::ReferenceData::SEXES,
        study_mode: ::ReferenceData::STUDY_MODES,
        training_route: ::ReferenceData::TRAINING_ROUTES,
        training_initiative: ::ReferenceData::TRAINING_INITIATIVES,
      }.freeze

      def self.all
        self::TYPES.each_with_object({}) do |(name, type), hash|
          hash[name] = values_for(name, type)
        end.freeze
      end

      # rubocop:disable Style/HashEachMethods
      def self.entries_for(type_name, type)
        rows = []
        type.values.each do |value|
          Array(value.hesa_codes).each do |code|
            next if code.blank?

            rows << {
              hesa_code: code,
              display_name: I18n.t("#{type_name}.#{code}", default: value.display_name),
              start_year: value.start_year,
              end_year: value.end_year,
            }
          end
        end
        rows.sort_by { |entry| entry[:hesa_code] }
      end
      # rubocop:enable Style/HashEachMethods

      def self.values_for(type_name, type)
        entries_for(type_name, type).map { |entry| [entry[:hesa_code], entry[:display_name]] }
      end

      def self.docs_payload
        self::TYPES.each_with_object({}) do |(name, type), hash|
          hash[name] = {
            metadata: type.metadata,
            entries: entries_for(name, type),
          }
        end.freeze
      end
    end
  end
end
