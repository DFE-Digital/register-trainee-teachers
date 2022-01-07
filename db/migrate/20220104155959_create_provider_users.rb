# frozen_string_literal: true

class CreateProviderUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :provider_users do |t|
      t.references :provider, null: false, foreign_key: true, index: true
      t.references :user, null: false, foreign_key: true, index: true

      t.timestamps
    end

    add_index :provider_users, %i[provider_id user_id], unique: true
  end
end
