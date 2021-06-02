# frozen_string_literal: true

class RouteDataManager
  attr_reader :trainee

  def initialize(trainee:)
    @trainee = trainee
  end

  def update_training_route!(route)
    trainee.update!(attributes(route))
  end

private

  def updated_course_details
    {
      course_code: nil,
      subject: nil,
      subject_two: nil,
      subject_three: nil,
      course_age_range: nil,
      course_start_date: nil,
      course_end_date: nil,
      progress: {
        course_details: false,
      },
    }
  end

  def attributes(route)
    {
      training_route: route,
    }.merge(updated_course_details)
  end
end
