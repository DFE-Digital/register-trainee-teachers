# frozen_string_literal: true

class AddBulkUpdateTraineeUploads < ActiveRecord::Migration[7.2]
  def change
    create_table :bulk_update_trainee_uploads do |t|
      t.references :provider, null: false, foreign_key: true
      t.text :file
      t.string :file_name
      t.integer :number_of_trainees
      t.string :status
      t.jsonb :error_messages
      t.timestamps
    end
  end
end
