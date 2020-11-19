# frozen_string_literal: true

class CreateTraineeDisabilities < ActiveRecord::Migration[6.0]
  def change
    create_table :trainee_disabilities do |t|
      t.references :trainee, index: true, null: false, foreign_key: { to_table: :trainees }
      t.references :disability, index: true, null: false, foreign_key: { to_table: :disabilities }
      t.timestamps
    end
  end
end
