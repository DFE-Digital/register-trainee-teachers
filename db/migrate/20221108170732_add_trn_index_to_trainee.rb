# frozen_string_literal: true

class AddTrnIndexToTrainee < ActiveRecord::Migration[6.1]
  def change
    add_index :trainees, :trn
  end
end
