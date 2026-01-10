# frozen_string_literal: true

module Api
  module V20260
    module HesaMapper
      class Attributes < Api::V20250::HesaMapper::Attributes
        def course_attributes
          attributes = {
            course_education_phase:,
            course_subject_one:,
            course_subject_two:,
            course_subject_three:,
            course_min_age:,
            course_max_age:,
            study_mode:,
            itt_start_date:,
            itt_end_date:,
            trainee_start_date:,
            course_allocation_subject:,
          }

          attributes[:course_allocation_subject_id] = attributes.delete(:course_allocation_subject)&.id

          attributes
        end
      end
    end
  end
end
