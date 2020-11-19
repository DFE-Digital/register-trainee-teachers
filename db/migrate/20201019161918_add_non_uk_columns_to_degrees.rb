# frozen_string_literal: true

class AddNonUkColumnsToDegrees < ActiveRecord::Migration[6.0]
  def change
    change_table :degrees, bulk: true do |t|
      t.column :country, :string, null: true
    end
  end
end
