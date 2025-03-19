# frozen_string_literal: true

class AddStatusToAuthenticationTokens < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_column :authentication_tokens, :status, :string, default: :active
    add_index :authentication_tokens, :status, algorithm: :concurrently
  end
end
