# frozen_string_literal: true

module Api
  module V01
    class HesaTraineeDetailAttributes
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Api::ErrorMessageHelpers

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
        course_year
        course_age_range
        fund_code
        funding_method
      ].freeze

      ITT_AIM_REQUIRED_CODE = "202"

      ATTRIBUTES.each do |attr|
        attribute attr
      end

      attr_accessor :trainee_attributes

      validates(*REQUIRED_ATTRIBUTES, presence: true)

      validates(:itt_qualification_aim, presence: true, if: -> { itt_aim == ITT_AIM_REQUIRED_CODE || itt_aim.blank? })

      validates :itt_aim, api_inclusion: {
        in: Hesa::CodeSets::IttAims::MAPPING.keys,
      }, allow_blank: true

      validates :itt_qualification_aim, api_inclusion: {
        in: Hesa::CodeSets::IttQualificationAims::MAPPING.keys,
      }, allow_blank: true

      validates :course_age_range, api_inclusion: {
        in: Hesa::CodeSets::AgeRanges::MAPPING.keys,
      }, allow_blank: true

      validates :funding_method, api_inclusion: {
        in: Hesa::CodeSets::BursaryLevels::MAPPING.keys,
      }, allow_blank: true
    end
  end
end
