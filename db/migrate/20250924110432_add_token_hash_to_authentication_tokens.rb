class AddTokenHashToAuthenticationTokens < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_column :authentication_tokens, :token_hash, :string
    add_index :authentication_tokens, :token_hash, unique: true, algorithm: :concurrently
  end
end
