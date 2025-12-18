# frozen_string_literal: true

class FixTraineeWithWrongFundingsMethodForGrant < ActiveRecord::Migration[6.1]
  def up
    all_early_years_subject_specialisms = AllocationSubject.find_by(name: "Early years ITT").subject_specialisms.pluck(:name)

    early_years_salaried = ReferenceData::TRAINING_ROUTES.early_years_salaried.named

    Trainee.where(applying_for_bursary: true, training_route: early_years_salaried, course_subject_one: all_early_years_subject_specialisms)
      .update_all(applying_for_bursary: nil, applying_for_grant: true)

    Trainee.where(applying_for_bursary: false, training_route: early_years_salaried, course_subject_one: all_early_years_subject_specialisms)
      .update_all(applying_for_bursary: nil, applying_for_grant: false)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
