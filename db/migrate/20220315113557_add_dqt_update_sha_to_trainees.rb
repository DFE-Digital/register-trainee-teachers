# frozen_string_literal: true

class AddDqtUpdateShaToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :dqt_update_sha, :string
  end
end
