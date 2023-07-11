# frozen_string_literal: true

class TraineeWithdrawalReasons < ActiveRecord::Migration[7.0]
  def up
    WithdrawalReason.upsert_all(WithdrawalReasons::SEED, unique_by: :name)

    # Prepare an array to hold the hash values for bulk insert
    trainee_withdrawal_reasons = []

    Trainee.withdraw_reasons.each_key do |withdraw_reason|
      # Check if there's a mapping for the current withdraw_reason
      mapped_reason = WithdrawalReasons::LEGACY_MAPPING[withdraw_reason] || withdraw_reason

      # Find the corresponding withdrawal_reason_id
      withdrawal_reason_id = WithdrawalReason.find_by(name: mapped_reason).id

      # Get all trainee ids with this withdrawal reason
      trainee_ids = Trainee.where(withdraw_reason:).pluck(:id)

      # Prepare hash values for bulk insert
      trainee_withdrawal_reasons.concat(trainee_ids.map { |id| { trainee_id: id, withdrawal_reason_id: withdrawal_reason_id } })
    end

    # Perform bulk insert
    TraineeWithdrawalReason.insert_all(trainee_withdrawal_reasons) unless trainee_withdrawal_reasons.empty?
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
