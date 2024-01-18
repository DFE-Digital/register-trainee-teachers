# frozen_string_literal: true

class ProcessFundingCsvJob < ApplicationJob
  queue_as :default

  def perform(funding_upload)
    funding_importer = FundingDataImporter.new(funding_upload)
    funding_importer.import_data
  end
end
