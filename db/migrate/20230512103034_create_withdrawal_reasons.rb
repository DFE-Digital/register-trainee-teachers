# frozen_string_literal: true

class CreateWithdrawalReasons < ActiveRecord::Migration[7.0]
  def change
    create_table :withdrawal_reasons do |t|
      t.timestamps

      t.string :name, index: true, unique: true
      t.string :description, unique: true
    end
  end
end
