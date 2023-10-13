# frozen_string_literal: true

class AddSubmissionReadyIndexToTrainees < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :trainees, :submission_ready, algorithm: :concurrently
  end
end
