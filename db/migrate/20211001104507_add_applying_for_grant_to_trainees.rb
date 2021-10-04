# frozen_string_literal: true

class AddApplyingForGrantToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :applying_for_grant, :boolean
  end
end
