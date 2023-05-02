# frozen_string_literal: true

class RecalculateSubmissionReadyFieldForHesaTrainees < ActiveRecord::Migration[7.0]
  def up
    Trainee.where.missing(:nationalities).joins(:hesa_students).find_each do |trainee|
      Trainees::UpdateSubmissionReadinessJob.perform_later(trainee)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
