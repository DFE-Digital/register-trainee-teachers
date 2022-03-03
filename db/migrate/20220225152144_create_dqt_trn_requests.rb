# frozen_string_literal: true

class CreateDqtTrnRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :dqt_trn_requests do |t|
      t.references :trainee, index: true, null: false, foreign_key: { to_table: :trainees }
      t.uuid :request_id, null: false, index: { unique: true }
      t.jsonb :response
      t.integer :state, default: 0

      t.timestamps
    end
  end
end
