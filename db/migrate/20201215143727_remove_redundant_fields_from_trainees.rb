# frozen_string_literal: true

class RemoveRedundantFieldsFromTrainees < ActiveRecord::Migration[6.0]
  def change
    remove_column(:trainees, :ethnicity, :text)
    remove_column(:trainees, :disability, :text)
    remove_column(:trainees, :full_time_part_time, :text)
    remove_column(:trainees, :teaching_scholars, :text)
    remove_column(:trainees, :start_date, :date)
  end
end
