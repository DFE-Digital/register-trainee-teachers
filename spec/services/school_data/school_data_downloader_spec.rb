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

      it "returns the CSV content as a string" do
        result = described_class.call

        expect(result).to be_a(String)
        expect(result).to eq(sample_csv_data)
      end

      it "includes all schools without filtering" do
        result = described_class.call
        csv = CSV.parse(result, headers: true)

        expect(csv.count).to eq(4)
        expect(csv.map { |row| row["URN"] }).to contain_exactly("123456", "234567", "345678", "456789")
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

    context "when response has HTTP error status" do
      before do
        response_double = double("Net::HTTPResponse")
        allow(Net::HTTP).to receive(:get_response).and_return(response_double)
        allow(response_double).to receive(:value).and_raise(Net::HTTPError.new("404 Not Found", nil))
      end

      it "re-raises the HTTP error" do
        expect { described_class.call }.to raise_error(Net::HTTPError)
      end
    end
  end
end
