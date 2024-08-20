# frozen_string_literal: true

class AddRouteTypeToFundingTraineeSummaryRows < ActiveRecord::Migration[7.1]
  def change
    add_column :funding_trainee_summary_rows, :route_type, :string
  end
end
