# frozen_string_literal: true

class AddApplyingForScholarshipToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :applying_for_scholarship, :boolean
  end
end
