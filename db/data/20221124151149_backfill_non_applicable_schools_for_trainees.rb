# frozen_string_literal: true

class BackfillNonApplicableSchoolsForTrainees < ActiveRecord::Migration[6.1]
  def up
    urns = Trainees::CreateFromHesa::NOT_APPLICABLE_SCHOOL_URNS

    hesa_ids = Hesa::Student.where(lead_school_urn: urns).pluck(:hesa_id)
    Trainee.where(hesa_id: hesa_ids).update_all(lead_school_not_applicable: true) if hesa_ids.any?

    hesa_ids = Hesa::Student.where(employing_school_urn: urns).pluck(:hesa_id)
    Trainee.where(hesa_id: hesa_ids).update_all(employing_school_not_applicable: true) if hesa_ids.any?
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
