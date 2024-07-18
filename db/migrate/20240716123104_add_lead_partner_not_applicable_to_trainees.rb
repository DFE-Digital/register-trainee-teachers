# frozen_string_literal: true

class AddLeadPartnerNotApplicableToTrainees < ActiveRecord::Migration[7.1]
  def change
    add_column :trainees, :lead_partner_not_applicable, :boolean, default: false, null: false
  end
end
