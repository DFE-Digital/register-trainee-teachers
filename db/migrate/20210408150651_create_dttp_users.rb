# frozen_string_literal: true

class CreateDttpUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :dttp_users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :dttp_id, index: { unique: true }
      t.string :provider_dttp_id
      t.timestamps default: -> { "CURRENT_TIMESTAMP" }
    end
  end
end
