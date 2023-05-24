# frozen_string_literal: true

class CreatePlacements < ActiveRecord::Migration[7.0]
  def change
    create_table :placements do |t|
      t.belongs_to :trainee
      t.belongs_to :school

      t.string :urn
      t.string :name
      t.text :address
      t.string :postcode

      t.timestamps
    end
  end
end
