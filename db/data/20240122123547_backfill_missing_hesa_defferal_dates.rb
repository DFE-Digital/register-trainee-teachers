# frozen_string_literal: true

class BackfillMissingHesaDefferalDates < ActiveRecord::Migration[7.1]
  def up
    Trainee.deferred.joins(:hesa_students).where(defer_date: nil).find_each do |trainee|
      most_recent_itt_record = trainee.hesa_students.max_by(&:created_at)
      next unless most_recent_itt_record

      if Trainees::MapStateFromHesa.call(hesa_trainee: most_recent_itt_record, trainee: trainee) == :deferred
        trainee.update!(
          defer_date: most_recent_itt_record.end_date || most_recent_itt_record.itt_end_date || most_recent_itt_record.hesa_updated_at,
        )
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
