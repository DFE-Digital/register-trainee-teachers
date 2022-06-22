# frozen_string_literal: true

class RemoveCohortFromTrainees < ActiveRecord::Migration[6.1]
  def change
    remove_column :trainees, :cohort, :integer
  end
end
