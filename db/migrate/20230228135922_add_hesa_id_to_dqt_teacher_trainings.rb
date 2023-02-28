# frozen_string_literal: true

class AddHesaIdToDqtTeacherTrainings < ActiveRecord::Migration[7.0]
  def change
    add_column :dqt_teacher_trainings, :hesa_id, :string
  end
end
