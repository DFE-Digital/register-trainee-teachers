class RemoveAuthenticationTokensHashedTokenNotNullConstraint < ActiveRecord::Migration[7.2]
  def change
    change_column_null :authentication_tokens, :hashed_token, true
  end
end
