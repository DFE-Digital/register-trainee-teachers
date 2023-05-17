# frozen_string_literal: true

class TraineeWithdrawalReasons < ActiveRecord::Migration[7.0]
  def up
    # Create TraineeWithdrawalReason entries for each withdrawal reason
    Trainee.withdraw_reason.each_key do |withdraw_reason|
      # Check if there's a mapping for the current withdraw_reason
      mapped_reason = WithdrawalReasons::LEGACY_MAPPING[withdraw_reason] || withdraw_reason

      # Find the corresponding withdrawal_reason_id
      withdrawal_reason_id = WithdrawalReason.find_by(name: mapped_reason).id

      # Find all trainees with this withdrawal reason
      trainees = Trainee.where(withdraw_reason:)
      next unless trainees.any?

      # Create TraineeWithdrawalReason entries
      TraineeWithdrawReason.create(
        trainees.map do |trainee|
          { trainee_id: trainee.id, withdrawal_reason_id: withdrawal_reason_id }
        end,
      )
    end

    # Now nullify the old enum values
    Trainee.update_all(withdraw_reason: nil)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
