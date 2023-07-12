# frozen_string_literal: true

class FixIncorrectlyAwardedTrainee5676 < ActiveRecord::Migration[7.0]
  def up
    Trainee.find_by(slug: "NLqGn4CjW5JCtmmM9ugLGZa2")&.update!(state: :trn_received, awarded_at: nil, outcome_date: nil, recommended_for_award_at: nil, audit_comment: "Provider awarded the trainee in error")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
