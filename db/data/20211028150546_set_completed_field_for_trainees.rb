# frozen_string_literal: true

class SetCompletedFieldForTrainees < ActiveRecord::Migration[6.1]
  def up
    Trainee.find_each do |trainee|
      Trainees::UpdateSubmissionReadinessJob.perform_later(trainee)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
