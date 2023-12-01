# frozen_string_literal: true

class BackfillTraineeApplicationChoiceId < ActiveRecord::Migration[7.0]
  def up
    academic_cycle = AcademicCycle.for_year(2022)
    Trainee
      .where(start_academic_cycle: academic_cycle)
      .where(application_choice_id: nil).find_each do |trainee|
      BackfillApplicationChoiceId.call(trainee:)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
