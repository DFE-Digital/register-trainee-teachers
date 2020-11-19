# frozen_string_literal: true

class AddProgressFieldOnTrainees < ActiveRecord::Migration[6.0]
  def change
    change_table :trainees, bulk: true do |t|
      t.jsonb :progress, default: {}
    end

    add_index :trainees, :progress, using: :gin
  end
end
