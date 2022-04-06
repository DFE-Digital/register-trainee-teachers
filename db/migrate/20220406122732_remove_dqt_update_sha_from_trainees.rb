# frozen_string_literal: true

class RemoveDqtUpdateShaFromTrainees < ActiveRecord::Migration[6.1]
  def change
    remove_column :trainees, :dqt_update_sha, :string
  end
end
