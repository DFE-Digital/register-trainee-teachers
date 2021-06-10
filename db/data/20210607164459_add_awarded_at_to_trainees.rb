# frozen_string_literal: true

class AddAwardedAtToTrainees < ActiveRecord::Migration[6.1]
  # We want to start saving an awarded_at timestamp on a trainee, since the only
  # way to find out is to deduce from the audits.
  def up
    Trainee.awarded.each do |trainee|
      # state == 3 => "recommended_for_award"
      # state == 6 => "awarded"
      award_audit = trainee.audits.find { |audit| audit.audited_changes["state"] == [3, 6] }
      next unless award_audit

      trainee.update!(awarded_at: award_audit.created_at)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
