# frozen_string_literal: true

class RouteDataManager
  def initialize(trainee:)
    @trainee = trainee
  end

  def update_training_route!(route)
    trainee.training_route = route
    reset_trainee_details if trainee.training_route_changed?
    trainee.set_early_years_course_details
    trainee.save!
  end

private

  attr_reader :trainee

  def reset_trainee_details
    trainee.assign_attributes(course_details.merge(funding_details))
    reset_progress
  end

  def course_details
    {
      course_uuid: nil,
      course_education_phase: nil,
      course_subject_one: nil,
      course_subject_two: nil,
      course_subject_three: nil,
      course_age_range: nil,
      course_start_date: nil,
      course_end_date: nil,
      study_mode: nil,
    }
  end

  def funding_details
    {
      training_initiative: nil,
      applying_for_bursary: nil,
      applying_for_scholarship: nil,
      bursary_tier: nil,
    }
  end

  def reset_progress
    trainee.progress.course_details = false
    trainee.progress.funding = false
  end
end
