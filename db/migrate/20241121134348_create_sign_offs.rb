# frozen_string_literal: true

class CreateSignOffs < ActiveRecord::Migration[7.2]
  def change
    create_table :sign_offs do |t|
      t.references :provider, null: false, foreign_key: true
      t.references :academic_cycle, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :sign_off_type, null: false
      t.timestamps

      t.index %i[provider_id academic_cycle_id], unique: true
    end
  end
end
