# frozen_string_literal: true

class AddProgrammeEndDateToTrainees < ActiveRecord::Migration[6.0]
  def change
    add_column :trainees, :programme_end_date, :date, null: true
  end
end
