# frozen_string_literal: true

class CreateNationalisations < ActiveRecord::Migration[6.0]
  def change
    create_table :nationalisations, id: :uuid do |t|
      t.belongs_to :trainee, type: :uuid, index: true, null: false, foreign_key: { to_table: :trainees }
      t.belongs_to :nationality, type: :uuid, index: true, null: false, foreign_key: { to_table: :nationalities }
      t.timestamps
    end
  end
end
