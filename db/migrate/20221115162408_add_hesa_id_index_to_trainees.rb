# frozen_string_literal: true

class AddHesaIdIndexToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_index :trainees, :hesa_id
  end
end
