# frozen_string_literal: true

module Hesa
  module ReferenceData
    class V20260 < V20250
      def self.all
        {
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
        }.each_with_object({}) do |(name, type), hash|
          hash[name] = Hesa::ReferenceData::V20260.values_for(name, type)
        end.freeze
      end

      # rubocop:disable Style/HashEachMethods
      def self.values_for(type_name, type)
        rows = []
        type.values.each do |value|
          Array(value.hesa_codes).each do |code|
            next if code.blank?

            rows << [code, I18n.t("#{type_name}.#{code}", default: value.display_name)]
          end
        end
        rows.sort_by(&:first)
      end
      # rubocop:enable Style/HashEachMethods
    end
  end
end
