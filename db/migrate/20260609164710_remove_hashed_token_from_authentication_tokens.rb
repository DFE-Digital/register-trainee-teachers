# frozen_string_literal: true

class RemoveHashedTokenFromAuthenticationTokens < ActiveRecord::Migration[7.2]
  def up
    safety_assured { remove_column :authentication_tokens, :hashed_token }
  end

  def down
    safety_assured do
      add_column :authentication_tokens, :hashed_token, :string
      add_index :authentication_tokens, :hashed_token, unique: true
    end
  end
end
