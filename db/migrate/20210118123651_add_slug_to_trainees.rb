# frozen_string_literal: true

class AddSlugToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :slug, :string
    add_index :trainees, :slug, unique: true
  end
end
