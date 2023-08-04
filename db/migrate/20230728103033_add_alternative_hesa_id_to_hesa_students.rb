# frozen_string_literal: true

class AddAlternativeHesaIdToHesaStudents < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      # Remove from the trainees table as it should be on hesa_students
      remove_column :trainees, :previous_hesa_id, :string
      # Remove from the hesa_students table as we already have a `numhus` field for it
      remove_column :hesa_students, :student_instance_id, :string
    end

    add_column :hesa_students, :previous_hesa_id, :string
  end
end
