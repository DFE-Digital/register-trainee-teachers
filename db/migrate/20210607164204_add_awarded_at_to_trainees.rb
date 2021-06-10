# frozen_string_literal: true

class AddAwardedAtToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :awarded_at, :datetime
  end
end
