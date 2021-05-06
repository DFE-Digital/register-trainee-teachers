# frozen_string_literal: true

class AddUkprnToDttpProvider < ActiveRecord::Migration[6.1]
  def change
    add_column :providers, :ukprn, :string
  end
end
