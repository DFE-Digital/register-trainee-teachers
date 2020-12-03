# frozen_string_literal: true

class AddDttpIdToProviders < ActiveRecord::Migration[6.0]
  def change
    add_column :providers, :dttp_id, :uuid
  end
end
