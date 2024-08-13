# frozen_string_literal: true

class MigrateLeadSchoolToLeadPartnerForHesaStudents < ActiveRecord::Migration[7.1]
  def up
    Hesa::Student.find_each do |hesa_student|
      next if hesa_student.lead_school_urn.blank?

      hesa_student.update!(lead_partner_urn: hesa_student.lead_school_urn)
    end
  end

  def down
    Hesa::Student.find_each do |hesa_student|
      next if hesa_student.lead_partner_urn.blank?

      hesa_student.update!(lead_partner_urn: nil)
    end
  end
end
