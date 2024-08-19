# frozen_string_literal: true

class MigrateLeadSchoolToLeadParterForRecommendationUploads < ActiveRecord::Migration[7.1]
  def up
    BulkUpdate::RecommendationsUploadRow.find_each do |row|
      next if row.lead_school.blank?

      row.update!(lead_partner: row.lead_school)
    end
  end

  def down
    BulkUpdate::RecommendationsUploadRow.find_each do |row|
      next if row.lead_partner.blank?

      row.update!(lead_partner: nil)
    end
  end
end
