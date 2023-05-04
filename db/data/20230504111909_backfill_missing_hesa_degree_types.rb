# frozen_string_literal: true

class BackfillMissingHesaDegreeTypes < ActiveRecord::Migration[7.0]
  def up
    Trainee.joins(:hesa_students).find_each do |trainee|
      hesa_student = trainee.hesa_student_for_collection(Settings.hesa.current_collection_reference)
      hesa_degrees = hesa_student&.degrees&.map(&:with_indifferent_access)
      if hesa_degrees&.any? { |degree| degree[:degree_type] == "999" }
        Degrees::CreateFromHesa.call(trainee:, hesa_degrees:)

        # Recalculates the trainee's readiness for submission
        trainee.send(:set_submission_ready)
        trainee.save
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
