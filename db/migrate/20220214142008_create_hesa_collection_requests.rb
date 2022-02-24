# frozen_string_literal: true

class CreateHesaCollectionRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :hesa_collection_requests do |t|
      t.string :collection_reference
      t.datetime :requested_at
      t.datetime :updates_since
      t.text :response_body
      t.timestamps
    end
  end
end
