# frozen_string_literal: true

class AddSignOff < ActiveRecord::Migration[7.2]
  def change
    change_table :sign_offs do |t|
      t.references :provider, null: false, foreign_key: true
      t.references :academic_cycle, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.column :sign_off_type, :string, default: "performance_profile", null: false
      t.timestamps

      t.index :sign_off_type, algorithm: :concurrently
      t.index %i[provider_id academic_cycle_id sign_off_type], unique: true
    end
  end
end
