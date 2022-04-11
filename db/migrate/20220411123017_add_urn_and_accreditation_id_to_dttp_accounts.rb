# frozen_string_literal: true

class AddUrnAndAccreditationIdToDttpAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :dttp_accounts, :urn, :string
    add_column :dttp_accounts, :accreditation_id, :string
    add_index :dttp_accounts, :urn
    add_index :dttp_accounts, :accreditation_id
  end
end
