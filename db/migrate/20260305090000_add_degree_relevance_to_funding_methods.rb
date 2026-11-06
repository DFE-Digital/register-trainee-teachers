# frozen_string_literal: true

class AddDegreeRelevanceToFundingMethods < ActiveRecord::Migration[8.1]
  def change
    add_column :funding_methods, :degree_relevance, :integer
  end
end
