# frozen_string_literal: true

class AddReadOnlyToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :read_only, :boolean, default: false
  end
end
