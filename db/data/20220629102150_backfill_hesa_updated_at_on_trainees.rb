# frozen_string_literal: true

class BackfillHesaUpdatedAtOnTrainees < ActiveRecord::Migration[6.1]
  def up
    trainees = Trainee.imported_from_hesa.joins(:hesa_student)

    trainees.find_each do |trainee|
      trainee.update_columns(hesa_updated_at: trainee.hesa_student.hesa_updated_at)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
