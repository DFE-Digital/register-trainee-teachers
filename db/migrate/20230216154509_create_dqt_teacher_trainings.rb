# frozen_string_literal: true

class CreateDqtTeacherTrainings < ActiveRecord::Migration[7.0]
  def change
    create_table :dqt_teacher_trainings do |t|
      t.belongs_to :dqt_teacher
      t.column :programme_start_date, :string
      t.column :programme_end_date, :string
      t.column :programme_type, :string
      t.column :result, :string
      t.column :provider_ukprn, :string
      t.timestamps
    end
  end
end
