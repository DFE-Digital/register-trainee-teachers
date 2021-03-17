# frozen_string_literal: true

class CreateCourses < ActiveRecord::Migration[6.1]
  def change
    create_table :courses do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.references :provider, index: true, null: false, foreign_key: { to_table: :providers }
      t.index %i[provider_id code], unique: true
      t.timestamps
    end
  end
end
