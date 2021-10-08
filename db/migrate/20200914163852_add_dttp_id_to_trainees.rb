# frozen_string_literal: true

class AddDttpIdToTrainees < ActiveRecord::Migration[6.0]
  def change
    add_column :trainees, :dttp_id, :uuid
    add_index :trainees, :dttp_id
  end
end
