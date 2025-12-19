# frozen_string_literal: true

class UpdateTraineeSearchable < ActiveRecord::Migration[7.2]
  def up
    safety_assured do
      execute <<-SQL
        UPDATE trainees
        SET searchable = to_tsvector(
          'pg_catalog.simple',
          coalesce(first_names, '') || ' ' ||
          coalesce(middle_names, '') || ' ' ||
          coalesce(last_name, '') || ' ' ||
          coalesce(provider_trainee_id, '') || ' ' ||
          coalesce(trn, '')
        )
      SQL
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
