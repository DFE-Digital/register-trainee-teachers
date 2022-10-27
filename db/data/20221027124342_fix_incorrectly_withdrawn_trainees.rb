# frozen_string_literal: true

class FixIncorrectlyWithdrawnTrainees < ActiveRecord::Migration[6.1]
  def up
    revert_withdrawn_trainees_to_in_training
    nullify_incorrect_withdrawal_attributes
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

private

  def revert_withdrawn_trainees_to_in_training
    %w[k7rNMosKsKL3duex1H9sU8y9
       65KPThwSTuRLcdMQ7rm2J9au
       ukd8URw5t9HDyeqn772yoq6v
       YtH6EEdp9Tf5R6nP4Cgurge7
       tpDn8jxtwFxryMUSKK2ULUSd
       seDy2LDQbTCyyZzbZdN7kQ4g
       KBsS2ikppLpSGqdUnht7dGzm
       PUrq8swnX9XYpcHhE3HBaFpq
       1B5XifvejubeWWjG7TSRUZmg
       Rp9WaWT8vRRNf3usXaAiAuT8].each do |slug|
      Trainee.find_by(slug: slug)&.update_columns(state: :trn_received, withdraw_date: nil, withdraw_reason: nil, additional_withdraw_reason: nil)
    end
  end

  def nullify_incorrect_withdrawal_attributes
    # Remove withdrawal information from trn_received and deferred trainees
    %w[32xuJRJXqk8CctYoHVTnmQZW
       1uBHjdvXZMXRixWhuxNdh4vg
       KiSpScCsSyukAXPrmwRtqLV8
       zJN7GTDcHGtorbky4XKLe2Mv
       m7D7cuzLU5YyS8p3qn5sMP46].each do |slug|
      Trainee.find_by(slug: slug)&.update_columns(withdraw_date: nil, withdraw_reason: nil, additional_withdraw_reason: nil)
    end
  end
end
