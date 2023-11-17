# frozen_string_literal: true

class SluggifyExistingPlacements < ActiveRecord::Migration[7.0]
  def up
    Placement.where(slug: nil).in_batches.each_record(&:save!)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
