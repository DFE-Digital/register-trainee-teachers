# frozen_string_literal: true

class AddStateToTrainees < ActiveRecord::Migration[6.0]
  def change
    add_column :trainees, :state, :integer, default: 0
    add_index :trainees, :state
  end
end
