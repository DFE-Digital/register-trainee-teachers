# frozen_string_literal: true

class AddLeadPartnerNameToTraineeSummaryRow < ActiveRecord::Migration[7.2]
  def change
    add_column :funding_trainee_summary_rows, :lead_partner_name, :string
  end
end
