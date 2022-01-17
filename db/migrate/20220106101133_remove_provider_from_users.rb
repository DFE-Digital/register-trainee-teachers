# frozen_string_literal: true

class RemoveProviderFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_reference :users, :provider, index: true, null: false, foreign_key: { to_table: :providers }
  end
end
