require "rails_helper"

describe FundingDataImporter do
  let(:csv_path) { 'path/to/csv_file.csv' }
  let(:first_predicted_month_index) { 0 }

  describe '#import_data' do
    context 'when the file name matches "SDS_subject_breakdown"' do
      let(:csv_path) { 'path/to/SDS_subject_breakdown' }

      it 'calls the ProviderPaymentSchedulesImporter' do
        importer = FundingDataImporter.new(csv_path, first_predicted_month_index)
        expect(Funding::Parsers::ProviderPaymentSchedules).to receive(:to_attributes).with(file_path: csv_path)
        expect(Funding::ProviderPaymentSchedulesImporter).to receive(:call).with(attributes: anything, first_predicted_month_index: first_predicted_month_index)
        importer.import_data
      end

      it 'raises an error if ProviderPaymentSchedulesImporter returns missing IDs' do
        allow(Funding::Parsers::ProviderPaymentSchedules).to receive(:to_attributes)
        allow(Funding::ProviderPaymentSchedulesImporter).to receive(:call).and_return(['id1', 'id2'])
        importer = FundingDataImporter.new(csv_path, first_predicted_month_index)
        expect { importer.import_data }.to raise_error(RuntimeError, 'Provider accreditation ids: id1, id2 not found')
      end
    end

    context 'when the file name matches "SDS_Profile"' do
      let(:csv_path) { 'path/to/SDS_Profile' }

      it 'calls the LeadSchoolPaymentSchedulesImporter' do
        importer = FundingDataImporter.new(csv_path, first_predicted_month_index)
        expect(Funding::Parsers::LeadSchoolPaymentSchedules).to receive(:to_attributes).with(file_path: csv_path)
        expect(Funding::LeadSchoolPaymentSchedulesImporter).to receive(:call).with(attributes: anything, first_predicted_month_index: first_predicted_month_index)
        importer.import_data
      end

      it 'raises an error if LeadSchoolPaymentSchedulesImporter returns missing URNs' do
        allow(Funding::Parsers::LeadSchoolPaymentSchedules).to receive(:to_attributes)
        allow(Funding::LeadSchoolPaymentSchedulesImporter).to receive(:call).and_return(['urn1', 'urn2'])
        importer = FundingDataImporter.new(csv_path, first_predicted_month_index)
        expect { importer.import_data }.to raise_error(RuntimeError, 'Lead school URNs: urn1, urn2 not found')
      end
    end

    context 'when the file name matches "TB_summary_upload"' do
      let(:csv_path) { 'path/to/TB_summary_upload' }

      it 'calls the ProviderTraineeSummariesImporter' do
        importer = FundingDataImporter.new(csv_path, first_predicted_month_index)
        expect(Funding::Parsers::ProviderTraineeSummaries).to receive(:to_attributes).with(file_path: csv_path)
        expect(Funding::ProviderTraineeSummariesImporter).to receive(:call).with(attributes: anything)
        importer.import_data
      end

      it 'raises an error if ProviderTraineeSummariesImporter returns missing IDs' do
        allow(Funding::Parsers::ProviderTraineeSummaries).to receive(:to_attributes)
        allow(Funding::ProviderTraineeSummariesImporter).to receive(:call).and_return(['id1', 'id2'])
        importer = FundingDataImporter.new(csv_path, first_predicted_month_index)
        expect { importer.import_data }.to raise_error(RuntimeError, 'Provider accreditation ids: id1, id2 not found')
      end
    end

    context 'when the file name matches "TB_Profile"' do
      let(:csv_path) { 'path/to/TB_Profile' }

      it 'calls the LeadSchoolTraineeSummariesImporter' do
        importer = FundingDataImporter.new(csv_path, first_predicted_month_index)
        expect(Funding::Parsers::LeadSchoolTraineeSummaries).to receive(:to_attributes).with(file_path: csv_path)
        expect(Funding::LeadSchoolTraineeSummariesImporter).to receive(:call).with(attributes: anything)
        importer.import_data
      end

      it 'raises an error if LeadSchoolTraineeSummariesImporter returns missing URNs' do
        allow(Funding::Parsers::LeadSchoolTraineeSummaries).to receive(:to_attributes)
        allow(Funding::LeadSchoolTraineeSummariesImporter).to receive(:call).and_return(['urn1', 'urn2'])
        importer = FundingDataImporter.new(csv_path, first_predicted_month_index)
        expect { importer.import_data }.to raise_error(RuntimeError, 'Lead school URNs: urn1, urn2 not found')
      end
    end

    context 'when the file name does not match any pattern' do
      it 'does not call any importer' do
        importer = FundingDataImporter.new(csv_path, first_predicted_month_index)
        expect(importer).not_to receive(:import_provider_payment_schedules)
        expect(importer).not_to receive(:import_lead_school_payment_schedules)
        expect(importer).not_to receive(:import_provider_trainee_summaries)
        expect(importer).not_to receive(:import_lead_school_trainee_summaries)
        importer.import_data
      end
    end
  end
end
