# frozen_string_literal: true

class UpdateBaEducationDegreesInDttp < ActiveRecord::Migration[6.1]
  # We had accidentally mapped BA/Education to BTech/Education in DTTP.
  # This migration finds all affected trainees (~65) and updates them in DTTP.
  def up
    degrees = Degree.where(uk_degree: "BA/Education")

    Trainee.where(id: degrees.pluck(:trainee_id)).each do |trainee|
      Dttp::UpdateTraineeJob.perform_later(trainee)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
