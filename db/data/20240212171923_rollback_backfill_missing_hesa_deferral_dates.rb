# frozen_string_literal: true

class RollbackBackfillMissingHesaDeferralDates < ActiveRecord::Migration[7.1]
  def up
    # Reset the defer_date of all trainees that are deferred and have a hesa student record where
    # defer_date matches their itt_end_date, or their itt_end_date is nil and defer_date matches their hesa_updated_at
    Trainee.deferred.find_each do |trainee|
      most_recent_itt_record = trainee.hesa_students.max_by(&:created_at)
      next unless most_recent_itt_record

      next unless Trainees::MapStateFromHesa.call(hesa_trainee: most_recent_itt_record, trainee: trainee) == :deferred

      if defer_date_matches_criteria?(trainee, most_recent_itt_record)
        trainee.update!(defer_date: nil)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

private

  def defer_date_matches_criteria?(trainee, most_recent_itt_record)
    trainee.defer_date == most_recent_itt_record.itt_end_date ||
      (most_recent_itt_record.itt_end_date.nil? && trainee.defer_date == most_recent_itt_record.hesa_updated_at)
  end
end
