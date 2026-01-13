# frozen_string_literal: true

class RenameLeadPartnersToTrainingPartners < ActiveRecord::Migration[7.2]
  def change
    safety_assured do
      rename_table :lead_partners, :training_partners
      rename_table :lead_partner_users, :training_partner_users

      rename_column :training_partner_users, :lead_partner_id, :training_partner_id

      rename_column :trainees, :lead_partner_id, :training_partner_id
      rename_column :trainees, :lead_partner_not_applicable, :training_partner_not_applicable

      rename_column :funding_trainee_summary_rows, :lead_partner_name, :training_partner_name
      rename_column :funding_trainee_summary_rows, :lead_partner_urn, :training_partner_urn

      rename_column :hesa_students, :lead_partner_urn, :training_partner_urn

      rename_column :bulk_update_recommendations_upload_rows, :lead_partner, :training_partner

      rename_column :school_data_downloads, :lead_partners_updated, :training_partners_updated
    end
  end
end
