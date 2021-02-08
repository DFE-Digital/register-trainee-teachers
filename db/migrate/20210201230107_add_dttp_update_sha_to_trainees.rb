# frozen_string_literal: true

class AddDttpUpdateShaToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :dttp_update_sha, :string
  end
end
