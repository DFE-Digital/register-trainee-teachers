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
          institution: ::ReferenceData::INSTITUTIONS,
          itt_aim: ::ReferenceData::ITT_AIMS,
          nationality: ::ReferenceData::NATIONALITIES,
          itt_qualification_aim: ::ReferenceData::ITT_QUALIFICATION_AIMS,
          sex: ::ReferenceData::SEXES,
          study_mode: ::ReferenceData::STUDY_MODES,
          training_route: ::ReferenceData::TRAINING_ROUTES,
          training_initiative: ::ReferenceData::TRAINING_INITIATIVES,
        }.transform_values do |type|
          Hesa::ReferenceData::V20260.values_for(type).to_h
        end.freeze
      end

      def self.values_for(type)
        transformed_values = []
        type.values.each do |value|
          hesa_codes = value.hesa_codes || []
          if hesa_codes.present?
            hesa_codes.each do |code|
              transformed_values << [code, value.display_name]
            end
          else
            transformed_values << ["-", value.display_name]
          end
        end.flatten
        transformed_values
      end
    end
  end
end
