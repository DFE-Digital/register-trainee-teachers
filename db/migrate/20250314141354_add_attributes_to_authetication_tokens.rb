# frozen_string_literal: true

class AddAttributesToAutheticationTokens < ActiveRecord::Migration[7.2]
  def change
    safety_assured do
      add_column :authentication_tokens, :name, :string
      add_column :authentication_tokens, :revoked, :boolean, default: false, null: false
      add_column :authentication_tokens, :revocation_date, :datetime
      add_column :authentication_tokens, :last_used_date, :datetime
      add_reference :authentication_tokens, :created_by, foreign_key: { to_table: :users }
      add_reference :authentication_tokens, :revoked_by, foreign_key: { to_table: :users }
    end
  end
end
