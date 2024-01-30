# frozen_string_literal: true

class BackfillMissingEducationPhases < ActiveRecord::Migration[6.1]
  def up
    Trainee.where.not(training_route: EARLY_YEARS_TRAINING_ROUTES.keys).where(course_education_phase: nil).find_each do |trainee|
      trainee.without_auditing do
        age_ranges = DfE::ReferenceData::AgeRanges::AGE_RANGES.all_as_hash
        trainee.update(course_education_phase: age_ranges.dig(trainee.course_age_range, :levels)&.first)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
