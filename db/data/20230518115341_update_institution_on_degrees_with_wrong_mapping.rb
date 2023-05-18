# frozen_string_literal: true

class UpdateInstitutionOnDegreesWithWrongMapping < ActiveRecord::Migration[7.0]
  def up
    # All these degrees have the wrong institution name, so we need to update them
    # The correct institution name should 'University of St Andrews' not 'University of St. Andrews'
    Degree.where(id: [92346, 92540, 84446, 83566, 84816, 84808, 85830]).find_each do |degree|
      degree.institution = "University of St Andrews"
      degree.save

      # Recalculates the trainee's readiness for submission
      trainee = degree.trainee
      trainee.send(:set_submission_ready)
      trainee.save
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
