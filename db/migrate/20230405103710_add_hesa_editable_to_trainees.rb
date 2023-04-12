# frozen_string_literal: true

class AddHesaEditableToTrainees < ActiveRecord::Migration[7.0]
  def change
    add_column :trainees, :hesa_editable, :boolean, default: false
  end
end
