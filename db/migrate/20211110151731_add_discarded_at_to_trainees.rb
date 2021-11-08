# frozen_string_literal: true

class AddDiscardedAtToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :discarded_at, :datetime
    add_index :trainees, :discarded_at
  end
end
