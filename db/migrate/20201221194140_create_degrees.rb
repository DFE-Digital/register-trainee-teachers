# frozen_string_literal: true

class CreateDegrees < ActiveRecord::Migration[6.0]
  def change
    create_table :degrees, id: :uuid do |t|
      t.belongs_to :trainee, type: :uuid, index: true, null: false, foreign_key: { to_table: :trainees }
      t.integer :locale_code, null: false, index: true
      t.string :uk_degree
      t.string :non_uk_degree
      t.string :subject, null: false
      t.string :institution
      t.integer :graduation_year, null: false
      t.string :grade
      t.string :country
      t.text :other_grade
      t.timestamps
    end
  end
end
