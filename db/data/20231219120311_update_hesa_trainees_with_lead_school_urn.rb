# frozen_string_literal: true

class UpdateHesaTraineesWithLeadSchoolUrn < ActiveRecord::Migration[7.1]
  def up
    trainees.each do |trainee|
      lead_shool = find_lead_school(trainee)

      next unless lead_shool

      trainee.update(lead_shool: lead_shool, lead_school_not_applicable: false)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

private

  def trainees
    Trainee.left_joins(:hesa_students)
           .where(lead_school_id: nil)
           .where.not(hesa_students: { lead_school_urn: %w[900000 900010 900020 900030] })
           .where.not(hesa_students: { lead_school_urn: nil })
           .distinct
  end

  def find_lead_school(trainee)
    latest_hesa_student_record = trainee.hesa_students.order(updated_at: :desc).first

    return if latest_hesa_student_record&.lead_shool_urn.blank?

    School.find_by(
      urn: latest_hesa_student_record.lead_school_urn,
      lead_shool: true,
    )
  end
end
