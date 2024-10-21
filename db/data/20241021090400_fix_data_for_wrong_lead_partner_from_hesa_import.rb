# frozen_string_literal: true

class FixDataForWrongLeadPartnerFromHesaImport < ActiveRecord::Migration[7.2]
  def up
    # This migration is to fix the data for the records that were imported from HESA (created or updated) and were incorrectly assigned the lead_partner_id of 1335
    Trainee.where(lead_partner_id: 1335, record_source: %w[hesa_collection hesa_trn_data]).update_all(lead_partner_id: nil, lead_partner_not_applicable: true)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
