# frozen_string_literal: true

class BackfillVeteranTeachingUndergraduateBursaryInitiative < ActiveRecord::Migration[7.0]
  def up
    trainees_with_veterans_bursary_level.each do |trainee|
      trainee.update(
        training_initiative: ROUTE_INITIATIVES_ENUMS[:veterans_teaching_undergraduate_bursary],
        applying_for_bursary: true,
        audit_comment: "Backfilled by data migration for https://trello.com/c/Meh5yeHA/6012-check-if-we-set-veteran-teaching-undergraduate-bursary-initiative-from-hesa-fburslev-code-c-if-not-action-this",
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

private

  def trainees_with_veterans_bursary_level
    Trainee
      .joins(:hesa_students)
      .where(hesa_students: { bursary_level: "C" })
      .distinct
  end
end
