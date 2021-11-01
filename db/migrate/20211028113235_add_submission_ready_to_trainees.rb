# frozen_string_literal: true

class AddSubmissionReadyToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :submission_ready, :boolean, default: false
  end
end
