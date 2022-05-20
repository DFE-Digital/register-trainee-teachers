# frozen_string_literal: true

class BackfillDeferralDatesForHesaTrainees < ActiveRecord::Migration[6.1]
  def up
    Trainee.deferred.joins(:hesa_student).where(defer_date: nil).each do |trainee|
      trainee.without_auditing do
        trainee.update(defer_date: trainee.hesa_student.end_date)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
