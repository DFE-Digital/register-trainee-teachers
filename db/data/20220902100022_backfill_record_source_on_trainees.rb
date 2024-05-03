# frozen_string_literal: true

class BackfillRecordSourceOnTrainees < ActiveRecord::Migration[6.1]
  def up
    Trainee.where(created_from_dttp: true, hesa_id: nil)
           .update_all(record_source: Trainee::DTTP_SOURCE)

    Trainee.where.not(hesa_id: nil)
           .where(record_source: Trainee::NON_TRN_SOURCES.push(nil))
           .update_all(record_source: Trainee::HESA_COLLECTION_SOURCE)

    Trainee.where.not(apply_application: nil)
           .update_all(record_source: Trainee::APPLY_SOURCE)

    Trainee.where(apply_application: nil, created_from_dttp: false, hesa_id: nil)
           .update_all(record_source: Trainee::MANUAL_SOURCE)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
