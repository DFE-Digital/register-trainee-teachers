class AddUniquenessIndexToAuthenticationTokens < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :authentication_tokens, :hashed_token, unique: true, algorithm: :concurrently
  end
end
