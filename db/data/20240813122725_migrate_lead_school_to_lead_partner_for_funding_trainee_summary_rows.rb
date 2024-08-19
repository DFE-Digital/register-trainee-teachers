# frozen_string_literal: true

class MigrateLeadSchoolToLeadPartnerForFundingTraineeSummaryRows < ActiveRecord::Migration[7.1]
  def up
    Funding::TraineeSummaryRow.find_each do |row|
      next if row.lead_school_urn.blank?

      row.update!(lead_partner_urn: row.lead_school_urn)
    end
  end

  def down
    Funding::TraineeSummaryRow.find_each do |row|
      next if row.lead_partner_urn.blank?

      row.update!(lead_partner_urn: nil)
    end
  end
end
