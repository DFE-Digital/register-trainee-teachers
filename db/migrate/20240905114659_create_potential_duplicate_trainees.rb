class CreatePotentialDuplicateTrainees < ActiveRecord::Migration[7.2]
  def change
    create_table :potential_duplicate_trainees do |t|
      t.uuid :group_id, null: false
      t.references :trainee, null: false, foreign_key: true
      t.timestamps
    end

    add_index :potential_duplicate_trainees, :group_id, unique: false
  end
end
