# frozen_string_literal: true

class AddRecommendedForQtsAtToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :recommended_for_qts_at, :datetime
  end
end
