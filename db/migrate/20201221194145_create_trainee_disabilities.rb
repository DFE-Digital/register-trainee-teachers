# frozen_string_literal: true

class CreateTraineeDisabilities < ActiveRecord::Migration[6.0]
  def change
    create_table :trainee_disabilities, id: :uuid do |t|
      t.belongs_to :trainee, type: :uuid, index: true, null: false, foreign_key: { to_table: :trainees }
      t.belongs_to :disability, type: :uuid, index: true, null: false, foreign_key: { to_table: :disabilities }
      t.text :additional_disability
      t.timestamps
    end
  end
end
