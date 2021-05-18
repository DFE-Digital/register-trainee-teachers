# frozen_string_literal: true

class RemoveAgeRangeFromTrainees < ActiveRecord::Migration[6.1]
  def change
    remove_column :trainees, :age_range, type: :integer
  end
end
