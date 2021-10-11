# frozen_string_literal: true

class AddCourseUuidToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :course_uuid, :uuid
  end
end
