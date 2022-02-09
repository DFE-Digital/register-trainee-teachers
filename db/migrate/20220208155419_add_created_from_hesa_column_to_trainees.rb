# frozen_string_literal: true

class AddCreatedFromHesaColumnToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :created_from_hesa, :boolean, default: false, null: false
  end
end
