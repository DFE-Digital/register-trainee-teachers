# frozen_string_literal: true

class FixUpIncompleteForExistingTrainees < ActiveRecord::Migration[6.1]
  def up
    states = %w[draft recommended_for_award withdrawn awarded]

    Trainee.where.not(state: states).find_each do |trainee|
      Trainees::UpdateSubmissionReadinessJob.perform_later(trainee)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
