# frozen_string_literal: true

class AddIndexToDttpId < ActiveRecord::Migration[6.1]
  def change
    add_index :providers, :dttp_id, unique: true
    add_index :users, :dttp_id, unique: true
  end
end
