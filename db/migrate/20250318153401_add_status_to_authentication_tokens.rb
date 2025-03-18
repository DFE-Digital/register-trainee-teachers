# frozen_string_literal: true

class AddStatusToAuthenticationTokens < ActiveRecord::Migration[7.2]
  def change
    add_column :authentication_tokens, :status, :string, default: :active
  end
end
