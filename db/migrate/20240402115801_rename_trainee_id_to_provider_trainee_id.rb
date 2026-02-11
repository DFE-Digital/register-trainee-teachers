# frozen_string_literal: true

class RenameTraineeIdToProviderTraineeId < ActiveRecord::Migration[6.0]
  def up
    add_column :trainees, :provider_trainee_id, :text

    safety_assured {
      execute <<~SQL.squish
        UPDATE trainees
        SET provider_trainee_id = trainee_id
      SQL
    }

    safety_assured { remove_column :trainees, :trainee_id }
  end

  def down
    add_column :trainees, :trainee_id, :text

    safety_assured {
      execute <<~SQL.squish
        UPDATE trainees
        SET trainee_id = provider_trainee_id
      SQL
    }

    safety_assured { remove_column :trainees, :provider_trainee_id }
  end
end
