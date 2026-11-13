# frozen_string_literal: true

class AddFundingConditionsToFundingMethods < ActiveRecord::Migration[8.1]
  def change
    add_column :funding_methods, :degree_relevance, :string
    add_column :funding_methods, :school_disadvantage, :string
  end
end
