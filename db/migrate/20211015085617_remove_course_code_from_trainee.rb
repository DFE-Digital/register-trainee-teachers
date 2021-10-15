# frozen_string_literal: true

class RemoveCourseCodeFromTrainee < ActiveRecord::Migration[6.1]
  def change
    remove_column :trainees, :course_code, :string
    add_index :trainees, :course_uuid
  end
end
