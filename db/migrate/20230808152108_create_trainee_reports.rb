# frozen_string_literal: true

class CreateTraineeReports < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_view :trainee_reports, materialized: true

    add_index :trainee_reports, :id, unique: true, algorithm: :concurrently
  end
end
