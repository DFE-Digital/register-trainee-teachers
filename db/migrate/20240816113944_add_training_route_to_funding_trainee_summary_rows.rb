# frozen_string_literal: true

class AddTrainingRouteToFundingTraineeSummaryRows < ActiveRecord::Migration[7.2]
  def change
    add_column :funding_trainee_summary_rows, :training_route, :string
  end
end
