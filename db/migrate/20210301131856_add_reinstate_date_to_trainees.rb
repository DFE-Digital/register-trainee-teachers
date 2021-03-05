# frozen_string_literal: true

class AddReinstateDateToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :reinstate_date, :date
  end
end
