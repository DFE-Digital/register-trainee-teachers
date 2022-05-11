# frozen_string_literal: true

class ChangeAmountToAmountInPenceForTraineeSummaryRowAmounts < ActiveRecord::Migration[6.1]
  def change
    rename_column :funding_trainee_summary_row_amounts, :amount, :amount_in_pence
  end
end
