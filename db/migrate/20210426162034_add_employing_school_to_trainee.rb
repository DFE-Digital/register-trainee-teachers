# frozen_string_literal: true

class AddEmployingSchoolToTrainee < ActiveRecord::Migration[6.1]
  def change
    add_reference :trainees, :employing_school, foreign_key: { to_table: "schools" }
  end
end
