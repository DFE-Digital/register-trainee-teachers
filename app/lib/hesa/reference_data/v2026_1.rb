# frozen_string_literal: true

module Hesa
  module ReferenceData
    class V20261 < V20260
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
          iqts_country: ::ReferenceData::IQTS_COUNTRIES,
        }.transform_values do |type|
          Hesa::ReferenceData::V20261.values_for(type)
        end.freeze
      end
    end
  end
end
