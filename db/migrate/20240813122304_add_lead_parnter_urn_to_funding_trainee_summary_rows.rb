# frozen_string_literal: true

class AddLeadParnterUrnToFundingTraineeSummaryRows < ActiveRecord::Migration[7.1]
  def change
    add_column :funding_trainee_summary_rows, :lead_partner_urn, :string
  end
end
