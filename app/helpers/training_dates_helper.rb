# frozen_string_literal: true

module TrainingDatesHelper
  def date_before_course_start_date?(commencement_date, course_start_date)
    return false if course_start_date.blank?

    commencement_date < course_start_date
  end
end
