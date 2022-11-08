# frozen_string_literal: true

require "rails_helper"

RSpec.describe CsvReportService do
  describe "#call" do
    let(:report_data) { described_class.call(report_class, scope: []) }
    let(:csv_data) { CSV.parse report_data }
    let(:csv_expected_data) { [report_class.headers] }
    let(:report_class) { Reports::TraineesReport }

    it "generates a csv with the correct headers" do
      allow(report_class).to receive(:headers).and_return(["headers"])

      report_data

      expect(csv_data[0]).to eq ["headers"]
    end
  end
end
