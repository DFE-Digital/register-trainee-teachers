# frozen_string_literal: true

class PrefixTraineeSubjectColumnsWithCourse < ActiveRecord::Migration[6.1]
  def change
    rename_column :trainees, :subject, :course_subject_one
    rename_column :trainees, :subject_two, :course_subject_two
    rename_column :trainees, :subject_three, :course_subject_three
  end
end
