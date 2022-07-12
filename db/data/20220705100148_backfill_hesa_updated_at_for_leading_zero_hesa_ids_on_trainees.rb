# frozen_string_literal: true

class BackfillHesaUpdatedAtForLeadingZeroHesaIdsOnTrainees < ActiveRecord::Migration[6.1]
  def up
    trainees = Trainee.imported_from_hesa.where(hesa_updated_at: nil)

    trainees.find_each do |trainee|
      hesa_trainee = Hesa::Student.find_by(hesa_id: strip_leading_zero(trainee.hesa_id))
      trainee.update_columns(hesa_updated_at: hesa_trainee.hesa_updated_at) if hesa_trainee
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  def strip_leading_zero(hesa_id)
    hesa_id.to_i.to_s
  end
end
