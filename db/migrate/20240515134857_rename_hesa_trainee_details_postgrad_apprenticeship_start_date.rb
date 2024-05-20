# frozen_string_literal: true

class RenameHesaTraineeDetailsPostgradApprenticeshipStartDate < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      rename_column :hesa_trainee_details, :postgrad_apprenticeship_start_date, :pg_apprenticeship_start_date
    end
  end
end
