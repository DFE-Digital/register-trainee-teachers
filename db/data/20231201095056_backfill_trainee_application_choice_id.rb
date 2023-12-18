# frozen_string_literal: true

class BackfillTraineeApplicationChoiceId < ActiveRecord::Migration[7.0]
  def up
    BackfillApplicationChoiceIdJob.perform_later
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
