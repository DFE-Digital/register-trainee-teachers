# frozen_string_literal: true

class AddDttpIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :dttp_id, :uuid
  end
end
