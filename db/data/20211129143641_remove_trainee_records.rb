# frozen_string_literal: true

class RemoveTraineeRecords < ActiveRecord::Migration[6.1]
  def up
    Trainee.where(dttp_id: %w[
      dd9f6f8b-3449-ec11-8c62-000d3ab0691d
      e61e03af-3449-ec11-8c62-000d3ab8e8ce
      e96eedfc-3049-ec11-8c62-000d3ab8e8ce
    ]).each(&:destroy)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
