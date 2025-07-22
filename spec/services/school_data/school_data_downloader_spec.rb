# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolData::SchoolDataDownloader do
  include ActiveSupport::Testing::TimeHelpers

  describe "#call" do
    context "when download succeeds" do
      let(:sample_csv_data) do
        "URN,EstablishmentName,TypeOfEstablishment (code),Postcode,Town\n" \
          "123456,Test Primary School,1,AB1 2CD,TestTown\n" \
          "234567,Test Academy,10,EF3 4GH,TestCity\n" \
          "345678,Test Independent School,4,IJ5 6KL,TestVillage\n" \
          "456789,Test Secondary School,15,MN7 8OP,TestDistrict"
      end

      before do
        response_double = double("Net::HTTPResponse")
        allow(Net::HTTP).to receive(:get_response).and_return(response_double)
        allow(response_double).to receive(:value) # Don't raise for successful response
        allow(response_double).to receive(:body).and_return(sample_csv_data)
      end

      it "returns the filtered CSV file path" do
        result = described_class.call

        expect(result).to be_a(String)
        expect(File.exist?(result)).to be true
      end

      it "filters rows based on establishment types" do
        filtered_csv_path = described_class.call

        filtered_content = File.read(filtered_csv_path)
        filtered_csv = CSV.parse(filtered_content, headers: true)

        # Should include schools with types 1, 10, and 15 but not 4
        expect(filtered_csv.count).to eq(3)
        expect(filtered_csv.map { |row| row["URN"] }).to contain_exactly("123456", "234567", "456789")
      end

      it "logs filtering results" do
        expect(Rails.logger).to receive(:info).with("Filtered 3 schools from 4 rows")

        described_class.call
      end
    end

    context "when download fails" do
      before do
        allow(Net::HTTP).to receive(:get_response).and_raise(Timeout::Error, "Network timeout")
      end

      it "re-raises the error (fail fast approach)" do
        expect { described_class.call }.to raise_error(Timeout::Error)
      end
    end

    context "when establishment type column is missing" do
      let(:invalid_csv) { "URN,Name\n123456,Test School" }

      before do
        response_double = double("Net::HTTPResponse")
        allow(Net::HTTP).to receive(:get_response).and_return(response_double)
        allow(response_double).to receive(:value)
        allow(response_double).to receive(:body).and_return(invalid_csv)
      end

      it "raises error for missing column" do
        expect { described_class.call }.to raise_error(/Could not find 'TypeOfEstablishment \(code\)' column/)
      end
    end

    context "when no schools match filter criteria" do
      let(:no_matching_csv) do
        "URN,EstablishmentName,TypeOfEstablishment (code),Postcode,Town\n" \
          "123456,Test School,99,AB1 2CD,TestTown"
      end

      before do
        response_double = double("Net::HTTPResponse")
        allow(Net::HTTP).to receive(:get_response).and_return(response_double)
        allow(response_double).to receive(:value)
        allow(response_double).to receive(:body).and_return(no_matching_csv)
      end

      it "creates filtered file with only headers" do
        filtered_csv_path = described_class.call

        filtered_content = File.read(filtered_csv_path)
        filtered_csv = CSV.parse(filtered_content, headers: true)

        expect(filtered_csv.count).to eq(0)
        expect(filtered_content).to include("URN,EstablishmentName")
      end

      it "logs zero filtered schools" do
        expect(Rails.logger).to receive(:info).with("Filtered 0 schools from 1 rows")

        described_class.call
      end
    end
  end
end
