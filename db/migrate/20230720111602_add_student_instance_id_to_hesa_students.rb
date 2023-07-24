# frozen_string_literal: true

class AddStudentInstanceIdToHesaStudents < ActiveRecord::Migration[7.0]
  def change
    add_column :hesa_students, :student_instance_id, :string
  end
end
