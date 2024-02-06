# frozen_string_literal: true

class CreateAuthenticationTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :authentication_tokens do |t|
      t.string :hashed_token, null: false
      t.boolean :enabled, default: true, null: false
      t.references :provider, foreign_key: true, null: false
      t.date :expires_at

      t.timestamps
    end
  end
end
