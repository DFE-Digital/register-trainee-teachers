# frozen_string_literal: true

class AddOutcomeDateToTrainees < ActiveRecord::Migration[6.0]
  def change
    add_column :trainees, :outcome_date, :date
  end
end
