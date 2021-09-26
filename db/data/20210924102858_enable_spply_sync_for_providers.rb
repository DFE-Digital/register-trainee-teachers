# frozen_string_literal: true

class EnableSpplySyncForProviders < ActiveRecord::Migration[6.1]
  def up
    Provider.update_all(apply_sync_enabled: true)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
