# frozen_string_literal: true

class FixTraineesWithIncorrectSubmissionReadyValue < ActiveRecord::Migration[7.0]
  def up
    trainees = Trainee.not_draft.where(submission_ready: false).where.not(state: Trainee::COMPLETE_STATES)

    trainees.find_each do |trainee|
      next if Submissions::MissingDataValidator.new(trainee:).missing_fields.any?

      trainee.send(:set_submission_ready)
      trainee.save!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
