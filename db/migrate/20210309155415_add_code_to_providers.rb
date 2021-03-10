# frozen_string_literal: true

class AddCodeToProviders < ActiveRecord::Migration[6.1]
  def change
    add_column :providers, :code, :string
  end
end
