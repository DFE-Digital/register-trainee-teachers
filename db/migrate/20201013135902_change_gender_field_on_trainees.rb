# frozen_string_literal: true

class ChangeGenderFieldOnTrainees < ActiveRecord::Migration[6.0]
  def change
    remove_column :trainees, :gender, :text

    change_table :trainees, bulk: true do |t|
      t.integer :gender, index: true
    end
  end
end
