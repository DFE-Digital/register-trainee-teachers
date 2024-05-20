# frozen_string_literal: true

class CreateLeadPartners < ActiveRecord::Migration[7.1]
  def change
    create_table :lead_partners do |t|
<<<<<<< HEAD
      t.citext :urn, null: false
      t.string :record_type, null: false
      t.string :name
      t.citext :ukprn
=======
      t.string :urn, null: false
      t.string :record_type, null: false
      t.string :name
      t.string :ukprn
>>>>>>> 2c6dc5660 (Add migration to create `lead_partners` table)
      t.references :school, null: true, foreign_key: true
      t.references :provider, null: true, foreign_key: true
      t.timestamps
    end

    add_index :lead_partners, :urn, unique: true
    add_index :lead_partners, :ukprn, unique: true
  end
end
