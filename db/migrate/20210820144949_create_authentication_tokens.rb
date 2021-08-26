# frozen_string_literal: true

class CreateAuthenticationTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :authentication_tokens do |t|
      t.bigint :user_id, null: false
      t.string :user_type, null: false
      t.string :hashed_token, null: false
      t.index :hashed_token, unique: true
      t.index %i[user_id user_type], name: "index_authentication_tokens_on_id_and_type"
      t.string :path
      t.datetime :used_at

      t.timestamps
    end
  end
end
