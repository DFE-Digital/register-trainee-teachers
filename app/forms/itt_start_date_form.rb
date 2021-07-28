# frozen_string_literal: true

class IttStartDateForm < MultiDateForm
private

  def date_field
    @date_field ||= :course_start_date
  end
end
