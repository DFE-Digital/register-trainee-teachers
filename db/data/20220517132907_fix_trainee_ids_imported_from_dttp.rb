# frozen_string_literal: true

class FixTraineeIdsImportedFromDttp < ActiveRecord::Migration[6.1]
  def up
    Trainee.joins(:hesa_student).where("trainees.trainee_id != hesa_students.trainee_id").find_each do |trainee|
      trainee.without_auditing do
        trainee.update(trainee_id: trainee.hesa_student.trainee_id)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
