# frozen_string_literal: true

class RemoveEnabledFromAuthenticationTokens < ActiveRecord::Migration[7.2]
  def change
    safety_assured { remove_column :authentication_tokens, :enabled, type: :boolean, default: true, null: false }
  end
end
