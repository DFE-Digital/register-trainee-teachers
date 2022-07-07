# frozen_string_literal: true

class BackfillHesaUpdatedAtForDttpTraineesOnTrainees < ActiveRecord::Migration[6.1]
  def up
    trainees = Trainee.imported_from_hesa.where(start_academic_cycle: AcademicCycle.current, hesa_updated_at: nil)

    trainees.each do |trainee|
      dttp_trainee = trainee.dttp_trainee
      trainee.update_columns(hesa_updated_at: find_hesa_placement_update_date_for(dttp_trainee)) if dttp_trainee
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  def find_hesa_placement_update_date_for(dttp_trainee)
    dttp_trainee.latest_placement_assignment.response["dfe_hesamodifiedon"] || dttp_trainee.latest_placement_assignment.response["dfe_hesacreatedon"]
  end
end
