# frozen_string_literal: true

class RemovePotentialDuplicateTrainee < ActiveRecord::Migration[7.2]
  def change
    drop_table :potential_duplicate_trainees do |t|
      t.uuid :group_id, null: false
      t.references :trainee, null: false, foreign_key: true
      t.timestamps

      t.index :group_id
    end
  end
end
