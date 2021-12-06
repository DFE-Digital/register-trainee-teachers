# frozen_string_literal: true

class AddAcademicCycleToFundingMethods < ActiveRecord::Migration[6.1]
  def change
    add_reference :funding_methods, :academic_cycle, foreign_key: true
  end
end
