# frozen_string_literal: true

class AddFundingEligibilityToTrainees < ActiveRecord::Migration[8.0]
  def change
    add_column :trainees, :funding_eligibility, :string
  end
end
