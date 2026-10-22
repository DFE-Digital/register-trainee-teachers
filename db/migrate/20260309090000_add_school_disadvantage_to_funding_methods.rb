# frozen_string_literal: true

class AddSchoolDisadvantageToFundingMethods < ActiveRecord::Migration[8.1]
  def change
    add_column :funding_methods, :school_disadvantage, :integer
  end
end
