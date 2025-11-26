# frozen_string_literal: true

class MakeExpiresAtNullFalseInAuthenticationTokens < ActiveRecord::Migration[7.2]
  def change
    safety_assured do
      change_column_null :authentication_tokens, :expires_at, false
    end
  end
end
