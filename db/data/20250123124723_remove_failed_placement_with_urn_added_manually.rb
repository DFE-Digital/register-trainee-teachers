# frozen_string_literal: true

class RemoveFailedPlacementWithUrnAddedManually < ActiveRecord::Migration[7.2]
  def up
    BulkUpdate::PlacementRow.failed.where(urn: "ADDED MANUALLY").delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
