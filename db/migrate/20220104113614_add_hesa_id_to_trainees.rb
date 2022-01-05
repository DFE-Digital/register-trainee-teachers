# frozen_string_literal: true

class AddHesaIdToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :hesa_id, :string
  end
end
