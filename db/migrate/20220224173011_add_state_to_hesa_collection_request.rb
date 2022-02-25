# frozen_string_literal: true

class AddStateToHesaCollectionRequest < ActiveRecord::Migration[6.1]
  def change
    add_column :hesa_collection_requests, :state, :integer
    add_index :trainees, :state
  end
end
