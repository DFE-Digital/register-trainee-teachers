# frozen_string_literal: true

class RenameQtsRecommendedDateFromTrainees < ActiveRecord::Migration[6.1]
  def change
    rename_column :trainees, :recommended_for_qts_at, :recommended_for_award_at
  end
end
