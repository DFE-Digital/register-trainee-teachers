# frozen_string_literal: true

class CreateFundingPublicationRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :funding_publication_requests do |t|
      t.references :academic_cycle, null: false, index: true
      t.integer :state, null: false, default: 0
      t.bigint :submitted_by_id
      t.datetime :submitted_at
      t.bigint :reviewed_by_id
      t.datetime :reviewed_at
      t.text :decision_notes

      t.timestamps
    end
  end
end
