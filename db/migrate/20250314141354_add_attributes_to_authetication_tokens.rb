# frozen_string_literal: true

class AddAttributesToAutheticationTokens < ActiveRecord::Migration[7.2]
  class AuthenticationToken < ApplicationRecord; end

  def change
    safety_assured do
      add_column :authentication_tokens, :name, :string, null: false, default: "Test token"
      add_column :authentication_tokens, :revoked_at, :datetime
      add_column :authentication_tokens, :last_used_at, :datetime
      add_reference :authentication_tokens, :created_by, foreign_key: { to_table: :users }
      add_reference :authentication_tokens, :revoked_by, foreign_key: { to_table: :users }

      # Ensure existing tokens have a created_by user and name going forward

      AuthenticationToken.find_each do |authentication_token|
        provider = authentication_token.provider

        authentication_token.update!(created_by: provider.users.kept.first)
      end

      change_column_null :authentication_tokens, :name, false
    end
  end
end
