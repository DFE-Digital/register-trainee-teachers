# frozen_string_literal: true

module CourseFormHelpers
  def clear_funding_information
    trainee.progress.funding = false

    trainee.assign_attributes({
      applying_for_bursary: nil,
      applying_for_scholarship: nil,
      applying_for_grant: nil,
      bursary_tier: nil,
    })
  end

  def clear_funding_information?
    trainee.course_allocation_subject_id_changed? || trainee.training_route_changed?
  end

  def course_allocation_subject
    SubjectSpecialism.find_by(name: course_subject_one)&.allocation_subject
  end
end
