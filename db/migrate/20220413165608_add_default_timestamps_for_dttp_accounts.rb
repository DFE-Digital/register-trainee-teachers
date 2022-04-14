# frozen_string_literal: true

class AddDefaultTimestampsForDttpAccounts < ActiveRecord::Migration[6.1]
  def change
    change_column_default :dttp_accounts, :created_at, from: nil, to: -> { "CURRENT_TIMESTAMP" }
    change_column_default :dttp_accounts, :updated_at, from: nil, to: -> { "CURRENT_TIMESTAMP" }
  end
end
