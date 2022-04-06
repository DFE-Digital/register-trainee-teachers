# frozen_string_literal: true

class CreateDttpAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :dttp_accounts do |t|
      t.uuid :dttp_id, nullable: false
      t.string :ukprn
      t.string :name
      t.jsonb :response
      t.timestamps
    end

    add_index :dttp_accounts, :dttp_id
    add_index :dttp_accounts, :ukprn
  end
end
