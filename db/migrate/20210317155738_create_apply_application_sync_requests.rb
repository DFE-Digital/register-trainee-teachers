# frozen_string_literal: true

class CreateApplyApplicationSyncRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :apply_application_sync_requests do |t|
      t.integer :response_code
      t.boolean :successful

      t.timestamps
    end
  end
end
