# frozen_string_literal: true

class AddRegionToTrainee < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :region, :string
  end
end
