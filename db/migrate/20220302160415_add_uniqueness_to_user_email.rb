# frozen_string_literal: true

class AddUniquenessToUserEmail < ActiveRecord::Migration[6.1]
  def change
    rename_index :users, "index_unique_active_users", "index_unique_active_dttp_users"
    remove_index :users, :email
    add_index :users, %i[email], unique: true, where: "discarded_at IS NULL", name: "index_unique_active_users"
  end
end
