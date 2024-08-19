# frozen_string_literal: true

class AddLeadPartnerUrnToHesaStudents < ActiveRecord::Migration[7.1]
  def change
    add_column :hesa_students, :lead_partner_urn, :string
  end
end
