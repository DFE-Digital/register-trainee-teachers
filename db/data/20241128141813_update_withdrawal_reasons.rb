# frozen_string_literal: true

class UpdateWithdrawalReasons < ActiveRecord::Migration[7.2]
  def up
    WithdrawalReason.upsert_all(WithdrawalReasons::SEED, unique_by: :name)
  end

  def down; end
end
