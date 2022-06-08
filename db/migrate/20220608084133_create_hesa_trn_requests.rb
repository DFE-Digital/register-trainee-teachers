# frozen_string_literal: true

class CreateHesaTrnRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :hesa_trn_requests do |t|
      t.string :collection_reference
      t.integer :state
      t.text :response_body
      t.timestamps
    end
  end
end
