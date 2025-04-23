# frozen_string_literal: true

class RemoveEnabledFromAuthenticationTokens < ActiveRecord::Migration[7.2]
  class AuthenticationToken < ApplicationRecord; end

  def up
    safety_assured do
      AuthenticationToken.where(status: "active", enabled: false).update_all(status: "revoked")

      remove_column :authentication_tokens, :enabled
    end
  end

  def down
    safety_assured do
      add_column :authentication_tokens, :enabled, :boolean, default: true, null: false

      AuthenticationToken.where(status: "revoked").update_all(status: "active", enabled: false)
    end
  end
end
