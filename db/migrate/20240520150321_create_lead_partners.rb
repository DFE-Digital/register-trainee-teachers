# frozen_string_literal: true

class CreateLeadPartners < ActiveRecord::Migration[7.1]
  def change
    create_table :lead_partners do |t|
      t.citext :urn, null: false
      t.string :record_type, null: false
      t.string :name
      t.citext :ukprn
      t.references :school, null: true, foreign_key: true
      t.references :provider, null: true, foreign_key: true
      t.timestamps
    end

    add_index :lead_partners, :urn, unique: true
    add_index :lead_partners, :ukprn, unique: true
  end
end
