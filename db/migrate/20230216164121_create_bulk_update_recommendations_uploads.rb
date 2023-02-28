# frozen_string_literal: true

class CreateBulkUpdateRecommendationsUploads < ActiveRecord::Migration[7.0]
  def change
    create_table :bulk_update_recommendations_uploads do |t|
      t.timestamps

      t.belongs_to :provider, null: false, foreign_key: true
    end
  end
end
