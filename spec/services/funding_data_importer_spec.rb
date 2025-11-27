# frozen_string_literal: true

require "rails_helper"

describe FundingDataImporter do
  describe "#import_data" do
    context 'when the funding_type is "lead_partner_trainee_summary"' do
      let(:funding_upload) { create(:funding_upload, :lead_partner_trainee_summary) }

      it "calls the TrainingPartnerTraineeSummariesImporter" do
        importer = FundingDataImporter.new(funding_upload)
        expect(Funding::TrainingPartnerTraineeSummariesImporter).to receive(:call).with(attributes: anything)
        importer.import_data
      end

      it "sets the funding_upload status to failed if TrainingPartnerTraineeSummariesImporter returns missing URNs" do
        allow(Funding::TrainingPartnerTraineeSummariesImporter).to receive(:call).and_return(%w[urn1 urn2])
        importer = FundingDataImporter.new(funding_upload)
        importer.import_data
        expect(funding_upload.reload.failed?).to be true
      end
    end

    context 'when the funding_type is "lead_partner_payment_schedule"' do
      let(:funding_upload) { create(:funding_upload, :lead_partner_payment_schedules) }

      it "calls the TrainingPartnerPaymentSchedulesImporter" do
        importer = FundingDataImporter.new(funding_upload)
        expect(Funding::Parsers::TrainingPartnerPaymentSchedules).to receive(:to_attributes)
        expect(Funding::TrainingPartnerPaymentSchedulesImporter).to receive(:call).with(attributes: anything, first_predicted_month_index: funding_upload.month)
        importer.import_data
      end

      it "sets the funding_upload status to failed if TrainingPartnerPaymentSchedulesImporter returns missing URNs" do
        allow(Funding::Parsers::TrainingPartnerPaymentSchedules).to receive(:to_attributes)
        allow(Funding::TrainingPartnerPaymentSchedulesImporter).to receive(:call).and_return(%w[urn1 urn2])
        importer = FundingDataImporter.new(funding_upload)
        importer.import_data
        expect(funding_upload.reload.failed?).to be true
      end
    end

    context 'when the funding_type is "provider_trainee_summary"' do
      let(:funding_upload) { create(:funding_upload, :provider_trainee_summary) }

      it "calls the ProviderTraineeSummariesImporter" do
        importer = FundingDataImporter.new(funding_upload)
        expect(Funding::Parsers::ProviderTraineeSummaries).to receive(:to_attributes)
        expect(Funding::ProviderTraineeSummariesImporter).to receive(:call).with(attributes: anything)
        importer.import_data
      end

      it "sets the funding_upload status to failed if ProviderTraineeSummariesImporter returns missing IDs" do
        allow(Funding::Parsers::ProviderTraineeSummaries).to receive(:to_attributes)
        allow(Funding::ProviderTraineeSummariesImporter).to receive(:call).and_return(%w[id1 id2])
        importer = FundingDataImporter.new(funding_upload)
        importer.import_data
        expect(funding_upload.reload.failed?).to be true
      end
    end

    context 'when the funding_type is "provider_payment_schedule"' do
      let(:funding_upload) { create(:funding_upload, :provider_payment_schedule) }

      it "calls the ProviderPaymentSchedulesImporter" do
        importer = FundingDataImporter.new(funding_upload)
        expect(Funding::Parsers::ProviderPaymentSchedules).to receive(:to_attributes)
        expect(Funding::ProviderPaymentSchedulesImporter).to receive(:call).with(attributes: anything, first_predicted_month_index: funding_upload.month)
        importer.import_data
      end

      it "sets the funding_upload status to failed if ProviderPaymentSchedulesImporter returns missing IDs" do
        allow(Funding::Parsers::ProviderPaymentSchedules).to receive(:to_attributes)
        allow(Funding::ProviderPaymentSchedulesImporter).to receive(:call).and_return(%w[id1 id2])
        importer = FundingDataImporter.new(funding_upload)
        importer.import_data
        expect(funding_upload.reload.failed?).to be true
      end
    end
  end
end
