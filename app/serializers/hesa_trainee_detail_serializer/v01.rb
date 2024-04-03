# frozen_string_literal: true

module HesaTraineeDetailSerializer
  class V01
    SERIALIZABLE_ATTRIBUTES = %i[
      course_age_range
      course_study_mode
      course_year
      funding_method
      itt_aim
      ni_number
      postgrad_apprenticeship_start_date
      previous_last_name
      hesa_disabilities
      additional_training_initiative
    ].freeze

    def initialize(trainee_details)
      @trainee_details = trainee_details
    end

    def as_hash
      SERIALIZABLE_ATTRIBUTES.index_with do |attr|
        @trainee_details&.attributes&.[](attr)
      end
    end
  end
end
