# frozen_string_literal: true

class BackfillRecordSourceOnTrainees < ActiveRecord::Migration[6.1]
  def up
    Trainee.where(created_from_dttp: true, hesa_id: nil)
           .update_all(record_source: RecordSources::DTTP)

    non_trn_data_sources = RecordSources::ALL - [RecordSources::HESA_TRN_DATA]

    Trainee.where.not(hesa_id: nil)
           .where(record_source: non_trn_data_sources.push(nil))
           .update_all(record_source: RecordSources::HESA_COLLECTION)

    Trainee.where.not(apply_application: nil)
           .update_all(record_source: RecordSources::APPLY)

    Trainee.where(apply_application: nil, created_from_dttp: false, hesa_id: nil)
           .update_all(record_source: RecordSources::MANUAL)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
