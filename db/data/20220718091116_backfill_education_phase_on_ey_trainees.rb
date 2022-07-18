# frozen_string_literal: true

class BackfillEducationPhaseOnEyTrainees < ActiveRecord::Migration[6.1]
  def up
    Trainee.where(training_route: EARLY_YEARS_TRAINING_ROUTES.keys)
      .update_all(course_education_phase: COURSE_EDUCATION_PHASE_ENUMS[:early_years])
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
