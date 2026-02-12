# frozen_string_literal: true

class RenameTraineeIdToProviderTraineeIdHesa < ActiveRecord::Migration[7.1]
  def up
    add_column :hesa_students, :provider_trainee_id, :string

    safety_assured {
      execute <<~SQL.squish
        UPDATE hesa_students
        SET provider_trainee_id = trainee_id
      SQL
    }

    safety_assured { remove_column :hesa_students, :trainee_id }
  end

  def down
    add_column :hesa_students, :trainee_id, :string

    safety_assured {
      execute <<~SQL.squish
        UPDATE hesa_students
        SET trainee_id = provider_trainee_id
      SQL
    }

    safety_assured { remove_column :hesa_students, :provider_trainee_id }
  end
end
