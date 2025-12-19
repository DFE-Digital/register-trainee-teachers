# frozen_string_literal: true

module Hesa
  module ReferenceData
    class V20260 < V20250
      def self.all
        {
          # TODO: Handle hyphenated type names
          "country": ::ReferenceData::COUNTRIES,
          "course_age_range": ::ReferenceData::V20260::COURSE_AGE_RANGES,
          "course_subject": ::ReferenceData::V20260::COURSE_SUBJECTS,
          "degree_subject": ::ReferenceData::V20260::DEGREE_SUBJECTS,
          "degree_grade": ::ReferenceData::V20260::DEGREE_GRADES,
          "degree_type": ::ReferenceData::V20260::DEGREE_TYPES,
          "disability": ::ReferenceData::V20260::DISABILITIES,
          "ethnicity": ::ReferenceData::V20260::ETHNICITIES,
          "fund_code": ::ReferenceData::V20260::FUND_CODES,
          "institution": ::ReferenceData::V20260::INSTITUTIONS,
          "itt_aim": ::ReferenceData::V20260::ITT_AIMS,
          "nationality": ::ReferenceData::V20260::NATIONALITIES,
          "itt_qualification_aim": ::ReferenceData::V20260::ITT_QUALIFICATION_AIMS,
          "sex": ::ReferenceData::V20260::SEXES,
          "study_mode": ::ReferenceData::V20260::STUDY_MODES,
          "training_route": ::ReferenceData::V20260::TRAINING_ROUTES,
          "training_initiative": ::ReferenceData::V20260::TRAINING_INITIATIVES,
        }.to_h do |type_name, type|
          # TODO: Flatten the hesa codes array
          transformed_mapping = type.values.map { |value| [value.hesa_codes.first, value.display_name] }
          [type_name, transformed_mapping.to_h]
        end.freeze
      end
    end
  end
end
