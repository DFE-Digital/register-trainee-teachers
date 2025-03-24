# frozen_string_literal: true

class AddExpiresAtIndexToAuthenticationTokens < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_index :authentication_tokens, :expires_at, algorithm: :concurrently
  end
end
