require_relative "20200902161712_add_course_details_fields_to_trainees"

class RevertAddCourseDetailsFieldsToTrainees < ActiveRecord::Migration[6.0]
  def change
    revert AddCourseDetailsFieldsToTrainees
  end
end
