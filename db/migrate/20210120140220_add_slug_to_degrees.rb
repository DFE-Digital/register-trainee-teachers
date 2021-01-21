# frozen_string_literal: true

class AddSlugToDegrees < ActiveRecord::Migration[6.1]
  def change
    add_column :degrees, :slug, :string
    add_index :degrees, :slug, unique: true
  end
end
