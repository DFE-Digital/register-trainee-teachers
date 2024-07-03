# frozen_string_literal: true

class AddLeadPartnerIdForeignKeyToTrainees < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :trainees, :lead_partners, validate: false
  end
end
