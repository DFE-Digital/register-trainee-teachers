# frozen_string_literal: true

class AddResponseToDttpProviders < ActiveRecord::Migration[6.1]
  def change
    add_column :dttp_providers, :response, :jsonb
  end
end
