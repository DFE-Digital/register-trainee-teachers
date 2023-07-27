# frozen_string_literal: true

class AddAlternativeHesaIdToTrainees < ActiveRecord::Migration[7.0]
  def change
    add_column :trainees, :previous_hesa_id, :string
  end
end
