# frozen_string_literal: true

class RemovePresenceValidationForCourseAgeRange < ActiveRecord::Migration[6.1]
  def change
    change_column_null :courses, :min_age, true
    change_column_null :courses, :max_age, true
  end
end
