# frozen_string_literal: true

class DropLeadSchoolFromRecommendationsUploadRows < ActiveRecord::Migration[7.2]
  def change
    safety_assured { remove_column :bulk_update_recommendations_upload_rows, :lead_school, :string }
  end
end
