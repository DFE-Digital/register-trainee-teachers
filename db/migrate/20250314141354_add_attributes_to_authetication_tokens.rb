# frozen_string_literal: true

class AddAttributesToAutheticationTokens < ActiveRecord::Migration[7.2]
  class AuthenticationToken < ApplicationRecord
    belongs_to :provider
    belongs_to :created_by, class_name: "User", optional: true
    belongs_to :revoked_by, class_name: "User", optional: true
  end

  def change
    safety_assured do
      add_column :authentication_tokens, :name, :string
      add_column :authentication_tokens, :revoked_at, :datetime
      add_column :authentication_tokens, :last_used_at, :datetime
      add_reference :authentication_tokens, :created_by, foreign_key: { to_table: :users }
      add_reference :authentication_tokens, :revoked_by, foreign_key: { to_table: :users }

      reversible do |dir|
        dir.up do
          # Ensure existing tokens have a created_by user and name going forward

          AuthenticationToken.find_each do |authentication_token|
            provider = authentication_token.provider

            authentication_token.update!(created_by: provider.users.kept.first, name: "Test token")
          end

          change_column_null :authentication_tokens, :name, false
        end
      end
    end
  end
end
