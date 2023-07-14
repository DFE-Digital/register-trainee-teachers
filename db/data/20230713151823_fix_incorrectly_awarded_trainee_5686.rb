# frozen_string_literal: true

class FixIncorrectlyAwardedTrainee5686 < ActiveRecord::Migration[7.0]
  def up
    [2047929,
     2048877,
     2050246,
     2047853,
     2048321].each do |trn|
      Trainee.find_by(trn:)&.update!(state: :trn_received, awarded_at: nil, outcome_date: nil, recommended_for_award_at: nil, audit_comment: "Provider awarded the trainee in error")
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
