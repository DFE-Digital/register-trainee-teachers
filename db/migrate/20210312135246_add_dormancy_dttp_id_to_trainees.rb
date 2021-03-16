# frozen_string_literal: true

class AddDormancyDttpIdToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :dormancy_dttp_id, :uuid
  end
end
