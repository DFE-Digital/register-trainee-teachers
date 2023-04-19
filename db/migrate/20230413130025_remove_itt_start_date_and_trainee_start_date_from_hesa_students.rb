# frozen_string_literal: true

class RemoveIttStartDateAndTraineeStartDateFromHesaStudents < ActiveRecord::Migration[7.0]
  def change
    remove_column :hesa_students, :trainee_start_date, :string
    remove_column :hesa_students, :itt_start_date, :string
  end
end
