# frozen_string_literal: true

class AddExtendedCourseConfirmedToTrainees < ActiveRecord::Migration[8.1]
  def change
    # Early years teacher degree apprenticeship (EYTDA): the provider confirmed
    # the course is longer than the usual 2 or 3 years set by the Level 5 declaration.
    add_column :trainees, :extended_course_confirmed, :boolean, default: false, null: false
  end
end
