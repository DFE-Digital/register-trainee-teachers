class AddRouteKeyToFundingTraineeSummaryRows < ActiveRecord::Migration[7.1]
  def change
    add_column :funding_trainee_summary_rows, :route_key, :string
  end
end
