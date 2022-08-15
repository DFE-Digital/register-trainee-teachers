# frozen_string_literal: true

class UpdateDisabilities < ActiveRecord::Migration[6.1]
  def up
    Disability.upsert_all(
      Diversities::SEED_DISABILITIES.map do |disability|
        disability.merge(created_at: Time.zone.now, updated_at: Time.zone.now)
      end,
      unique_by: :name,
    )
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
