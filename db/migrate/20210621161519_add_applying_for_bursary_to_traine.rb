# frozen_string_literal: true

class AddApplyingForBursaryToTraine < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :applying_for_bursary, :boolean
  end
end
