# frozen_string_literal: true

class RollbackBackfillMissingHesaDeferralDates < ActiveRecord::Migration[7.1]
  def up
    # Reset the defer_date of all trainees that are deferred and have a hesa student record where
    # defer_date matches their itt_end_date, or their itt_end_date is nil and defer_date matches their hesa_updated_at
    Trainee.deferred.where.not(hesa_id: nil).find_each do |trainee|
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
    defer_date = standardised_date(trainee.defer_date)
    itt_end_date = standardised_date(most_recent_itt_record.itt_end_date)
    hesa_updated_at = standardised_date(most_recent_itt_record.hesa_updated_at)

    defer_date == itt_end_date || (itt_end_date.nil? && defer_date == hesa_updated_at)
  end

  def standardised_date(date)
    date&.to_date&.iso8601
  end
end
