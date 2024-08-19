# frozen_string_literal: true

class AddLeadPartnerToBulkUpdateRecommendationsUploadRows < ActiveRecord::Migration[7.1]
  def change
    add_column :bulk_update_recommendations_upload_rows, :lead_partner, :string
  end
end
