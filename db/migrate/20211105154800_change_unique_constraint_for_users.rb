# frozen_string_literal: true

class ChangeUniqueConstraintForUsers < ActiveRecord::Migration[6.1]
  def change
    remove_index :users, :dttp_id, unique: true
    add_index :users, %i[dttp_id], unique: true, where: "discarded_at IS NULL", name: "index_unique_active_users"
  end
end
