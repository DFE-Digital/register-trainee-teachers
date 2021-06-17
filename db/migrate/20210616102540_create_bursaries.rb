# frozen_string_literal: true

class CreateBursaries < ActiveRecord::Migration[6.1]
  def change
    create_table :bursaries do |t|
      t.string :training_route, null: false
      t.integer :amount, null: false

      t.timestamps
    end
  end
end
