# frozen_string_literal: true

class AddDttpAccountsDttpIdIndex < ActiveRecord::Migration[6.1]
  def change
    remove_index :dttp_accounts, :dttp_id
    add_index :dttp_accounts, :dttp_id, unique: true
  end
end
