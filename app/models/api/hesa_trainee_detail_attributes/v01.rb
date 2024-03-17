# frozen_string_literal: true

module Api
  module HesaTraineeDetailAttributes
    class V01
      include ActiveModel::Model
      include ActiveModel::Attributes

      ATTRIBUTES = %i[
        course_age_range
        course_study_mode
        course_year
        funding_method
        itt_aim
        ni_number
        postgrad_apprenticeship_start_date
        previous_last_name
      ].freeze

      ATTRIBUTES.each do |attr|
        attribute attr
      end
    end
  end
end
