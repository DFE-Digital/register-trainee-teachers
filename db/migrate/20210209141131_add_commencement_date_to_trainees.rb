# frozen_string_literal: true

class AddCommencementDateToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :commencement_date, :date
  end
end
