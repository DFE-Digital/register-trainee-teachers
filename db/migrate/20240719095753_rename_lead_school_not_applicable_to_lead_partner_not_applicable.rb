# frozen_string_literal: true

class RenameLeadSchoolNotApplicableToLeadPartnerNotApplicable < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      rename_column :trainees, :lead_school_not_applicable, :lead_partner_not_applicable
    end
  end
end
