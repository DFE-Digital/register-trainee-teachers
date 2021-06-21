# frozen_string_literal: true

class RouteDataManager
  attr_reader :trainee

  def initialize(trainee:)
    @trainee = trainee
  end

  def update_training_route!(route)
    trainee.training_route = route
    trainee.update!(reset_course_details) if trainee.training_route_changed?
  end

private

  def reset_course_details
    {
      course_code: nil,
      course_subject_one: nil,
      course_subject_two: nil,
      course_subject_three: nil,
      course_age_range: nil,
      course_start_date: nil,
      course_end_date: nil,
      progress: {
        course_details: false,
      },
    }
  end
end
