# frozen_string_literal: true

class CourseEducationPhaseForm < TraineeForm
  FIELDS = %i[
    course_education_phase
  ].freeze

  attr_accessor(*FIELDS)

  validates :course_education_phase, presence: true

private

  def compute_fields
    trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
  end
end
