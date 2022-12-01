# frozen_string_literal: true

class FixMissingDegreesFromDttp < ActiveRecord::Migration[6.1]
  def up
    trainees_with_missing_degrees =
      Trainee
      .joins(dttp_trainee: [:degree_qualifications])
      .where("dttp_degree_qualifications.state": 0)
      .where(
        "NOT EXISTS (:degrees)",
        degrees: Degree.select(1).where("degrees.trainee_id = trainees.id"),
      )

    trainees_with_missing_degrees.find_each do |trainee|
      Degrees::CreateFromDttp.call(trainee:)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
