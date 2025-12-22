# frozen_string_literal: true

module Hesa
  module ReferenceData
    class V20260 < V20250
      def self.all
        {
          # TODO: Handle hyphenated type names
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
        }.to_h do |type_name, type|
          # TODO: Flatten the hesa codes array
          transformed_mapping = type.values.map { |value| [value.hesa_codes.first, value.display_name] }
          [type_name, transformed_mapping.to_h]
        end.freeze
      end
    end
  end
end
