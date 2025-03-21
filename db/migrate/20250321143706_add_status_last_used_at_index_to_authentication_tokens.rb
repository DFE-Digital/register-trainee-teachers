# frozen_string_literal: true

class AddStatusLastUsedAtIndexToAuthenticationTokens < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_index :authentication_tokens, %i[status last_used_at], algorithm: :concurrently
  end
end
