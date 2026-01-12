# frozen_string_literal: true

class RemoveRedundantHesaTables < ActiveRecord::Migration[7.2]
  def change
    remove_index :trainees, column: :hesa_trn_submission_id, name: :index_trainees_on_hesa_trn_submission_id

    safety_assured { remove_column :trainees, :hesa_trn_submission_id, :bigint }

    drop_table :hesa_trn_submissions do |t|
      t.text "payload"
      t.datetime "submitted_at", precision: nil
      t.timestamps
    end

    drop_table :hesa_trn_requests do |t|
      t.string "collection_reference"
      t.integer "state"
      t.text "response_body"
      t.timestamps
    end

    drop_table :hesa_collection_requests do |t|
      t.string "collection_reference"
      t.datetime "requested_at", precision: nil
      t.text "response_body"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "state"
      t.index ["state"], name: "index_hesa_collection_requests_on_state"
      t.timestamps
    end
  end
end
