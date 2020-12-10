# frozen_string_literal: true

class AddTrnAndTrnRequestedAtToTrainees < ActiveRecord::Migration[6.0]
  def change
    change_table :trainees, bulk: true do |t|
      t.column  :trn, :string
      t.column  :trn_requested_at, :datetime
    end
  end
end
