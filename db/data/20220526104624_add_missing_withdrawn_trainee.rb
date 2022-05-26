# frozen_string_literal: true

class AddMissingWithdrawnTrainee < ActiveRecord::Migration[6.1]
  def up
    # This trainee changed course, thus has 2 placement assignments. The data migration will create
    # a duplicate record for the first placement at the request of the provider.
    ActiveRecord::Base.transaction do
      dttp_trainee = Dttp::Trainee.find(29820)
      existing_trainee = dttp_trainee.trainee
      trainee_dttp_id = existing_trainee.dttp_id

      # Prevent existing trainee from creating duplicate
      existing_trainee.update_columns(dttp_id: nil)
      dttp_trainee.importable!

      # Re-import trainee using their first placement assignment
      previous_placement_assignment = dttp_trainee.placement_assignments[-1]
      duplicate_trainee = Trainees::CreateFromDttp.call(dttp_trainee: dttp_trainee,
                                                        placement_assignment: previous_placement_assignment)

      # We don't want the HESA importer finding and updating this record, so we'll remove the HESA ID. We also don't
      # want the Dttp::Trainee record to point back back this trainee (only the existing one).
      duplicate_trainee.update_columns(hesa_id: nil, dttp_id: nil)

      # The existing trainee is also in the wrong state.
      existing_trainee.update_columns(state: :trn_received,
                                      dttp_id: trainee_dttp_id,
                                      withdraw_date: nil,
                                      withdraw_reason: nil)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
