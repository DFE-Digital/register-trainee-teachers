# frozen_string_literal: true

class FixSubmissionReadyField < ActiveRecord::Migration[6.1]
  # Mark this cycle's submissions as ready for the states below as we consider them complete
  def up
    states = %w[recommended_for_award withdrawn awarded]
    Trainee.where(state: states, submission_ready: false).update_all(submission_ready: true)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
