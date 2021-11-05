# frozen_string_literal: true

class FixUpSubmissionReady < ActiveRecord::Migration[6.1]
  def up
    Trainee.where.not(state: :draft).find_each do |trainee|
      Trainees::UpdateSubmissionReadinessJob.perform_later(trainee)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
