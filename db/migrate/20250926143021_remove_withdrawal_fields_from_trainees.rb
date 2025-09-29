# frozen_string_literal: true

class RemoveWithdrawalFieldsFromTrainees < ActiveRecord::Migration[7.2]
  def change
    safety_assured do
      remove_columns :trainees,
                     :withdraw_date,
                     :withdraw_reasons_details,
                     :withdraw_reasons_dfe_details
    end
  end
end
