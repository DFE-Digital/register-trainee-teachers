# frozen_string_literal: true

class CreateHesaTrnSubmissions < ActiveRecord::Migration[6.1]
  def change
    create_table :hesa_trn_submissions do |t|
      t.text :payload
      t.datetime :submitted_at
      t.timestamps
    end
  end
end
