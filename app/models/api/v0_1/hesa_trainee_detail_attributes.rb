# frozen_string_literal: true

module Api
  module V01
    class HesaTraineeDetailAttributes
      include ActiveModel::Model
      include ActiveModel::Attributes

      ATTRIBUTES = %i[
        course_study_mode
        course_year
        ni_number
        pg_apprenticeship_start_date
        previous_last_name
        hesa_disabilities
        additional_training_initiative
        itt_aim
        itt_qualification_aim
        course_year
        course_age_range
        fund_code
        funding_method
      ].freeze

      REQUIRED_ATTRIBUTES = %i[
        itt_aim
        itt_qualification_aim
        course_year
        course_age_range
        fund_code
        funding_method
      ].freeze

      ATTRIBUTES.each do |attr|
        attribute attr
      end

      validates(*REQUIRED_ATTRIBUTES, presence: true)

      validates(:itt_aim, inclusion: { in: Hesa::CodeSets::IttAims::MAPPING.keys }, allow_blank: true)
      validates(:itt_qualification_aim, inclusion: { in: Hesa::CodeSets::IttQualificationAims::MAPPING.keys }, allow_blank: true)
      validates(:course_age_range, inclusion: { in: Hesa::CodeSets::AgeRanges::MAPPING.keys }, allow_blank: true)
      validates(:funding_method, inclusion: { in: Hesa::CodeSets::BursaryLevels::MAPPING.keys }, allow_blank: true)
    end
  end
end
