# frozen_string_literal: true

class ChangeBursariesToFundingMethods < ActiveRecord::Migration[6.1]
  def change
    rename_table :bursaries, :funding_methods
    add_column :funding_methods, :funding_type, :integer
  end
end
