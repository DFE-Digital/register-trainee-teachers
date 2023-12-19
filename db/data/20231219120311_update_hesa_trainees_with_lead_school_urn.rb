# frozen_string_literal: true

class UpdateHesaTraineesWithLeadSchoolUrn < ActiveRecord::Migration[7.1]
  def up
    trainees.each do |trainee|
      lead_shcool = find_lead_school(trainee)

      next unless lead_shcool

      trainee.update(lead_shcool: lead_shcool, lead_school_not_applicable: false)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

private

  def trainees
    Trainee.left_joins(:hesa_students)
           .where(lead_school_id: nil, lead_school_not_applicable: true)
           .where.not(hesa_students: { lead_school_urn: Trainees::CreateFromHesa::NOT_APPLICABLE_SCHOOL_URNS })
           .where.not(hesa_students: { lead_school_urn: nil })
           .distinct
  end

  def find_lead_school(trainee)
    latest_hesa_student_record = trainee.hesa_students.order(updated_at: :desc).first

    return if latest_hesa_student_record&.lead_shcool_urn.blank?

    School.find_by(
      urn: latest_hesa_student_record.lead_school_urn,
      lead_shcool: true,
    )
  end
end
