# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProcessFundingCsvJob do
  let(:funding_upload) { create(:funding_upload) }

  it "initializes FundingDataImporter with the correct funding_upload object" do
    expect(FundingDataImporter).to receive(:new).with(funding_upload).and_call_original
    described_class.perform_now(funding_upload)
  end

  it "calls the import_data method" do
    funding_data_importer = instance_double(FundingDataImporter)
    allow(FundingDataImporter).to receive(:new).and_return(funding_data_importer)

    expect(funding_data_importer).to receive(:import_data)
    described_class.perform_now(funding_upload)
  end
end
