# frozen_string_literal: true

class ValidateAddLeadPartnerIdForeignKeyToTrainees < ActiveRecord::Migration[7.1]
  def change
    validate_foreign_key :trainees, :lead_partners
  end
end
