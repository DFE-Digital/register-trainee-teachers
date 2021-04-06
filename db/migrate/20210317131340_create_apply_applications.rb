# frozen_string_literal: true

class CreateApplyApplications < ActiveRecord::Migration[6.1]
  def change
    create_table :apply_applications do |t|
      t.jsonb :application
      t.references :provider, index: true, null: false, foreign_key: { to_table: :providers }

      t.timestamps
    end
  end
end
