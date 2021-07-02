# frozen_string_literal: true

class AddBursaryTierToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :bursary_tier, :integer
  end
end
