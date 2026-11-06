# frozen_string_literal: true

class AddTrainingYearToFundingMethods < ActiveRecord::Migration[8.1]
  # Year of training (1–4) for routes funded per year, such as the Early years
  # teacher degree apprenticeship. Nil for funding that applies to the whole course.
  def change
    add_column :funding_methods, :training_year, :integer
  end
end
