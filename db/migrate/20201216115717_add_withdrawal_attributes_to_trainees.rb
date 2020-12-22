# frozen_string_literal: true

class AddWithdrawalAttributesToTrainees < ActiveRecord::Migration[6.0]
  def change
    change_table :trainees, bulk: true do |t|
      t.column  :withdraw_reason, :integer
      t.column  :withdraw_date, :datetime
      t.column  :additional_withdraw_reason, :string
    end
  end
end
