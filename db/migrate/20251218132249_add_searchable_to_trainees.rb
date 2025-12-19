# frozen_string_literal: true

class AddSearchableToTrainees < ActiveRecord::Migration[7.2]
  def change
    safety_assured do
      add_column :trainees, :searchable, :tsvector
      add_index :trainees, :searchable, using: :gin
    end
  end
end
