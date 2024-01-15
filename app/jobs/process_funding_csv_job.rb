class ProcessFundingCsvJob < ApplicationJob
  queue_as :default

  def perform(csv_path, first_predicted_month_index)
    funding_importer = FundingDataImporter.new(csv_path, first_predicted_month_index)
    funding_importer.import_data
  end
end
