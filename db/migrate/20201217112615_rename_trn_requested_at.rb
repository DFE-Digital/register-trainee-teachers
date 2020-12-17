# frozen_string_literal: true

class RenameTrnRequestedAt < ActiveRecord::Migration[6.0]
  def change
    rename_column :trainees, :trn_requested_at, :submitted_for_trn_at
  end
end
