# frozen_string_literal: true

class AddCohortToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :cohort, :integer, default: 0
    add_index :trainees, :cohort
  end
end
