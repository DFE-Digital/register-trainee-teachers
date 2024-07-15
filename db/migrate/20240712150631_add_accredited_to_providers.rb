# frozen_string_literal: true

class AddAccreditedToProviders < ActiveRecord::Migration[7.1]
  def change
    add_column :providers, :accredited, :boolean, null: false, default: true
  end
end
