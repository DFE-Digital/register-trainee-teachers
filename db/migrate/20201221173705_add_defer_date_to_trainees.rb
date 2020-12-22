# frozen_string_literal: true

class AddDeferDateToTrainees < ActiveRecord::Migration[6.0]
  def change
    add_column :trainees, :defer_date, :date
  end
end
