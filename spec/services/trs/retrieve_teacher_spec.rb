# frozen_string_literal: true

require "rails_helper"

module Trs
  describe RetrieveTeacher do
    describe "#call" do
      let(:trainee) { build(:trainee, trn: "1234567") }
      let(:response) { { "trn" => "1234567", "firstName" => "John", "lastName" => "Doe" } }

      before do
        allow(Client).to receive(:get).and_return(response)
      end

      it "calls the TRS API with the correct endpoint" do
        described_class.call(trainee:)
        expect(Client).to have_received(:get).with("/v3/persons/#{trainee.trn}")
      end

      it "returns the parsed response" do
        result = described_class.call(trainee:)
        expect(result).to eq(response)
      end

      context "when the API returns an error" do
        before do
          allow(Client).to receive(:get).and_raise(Client::HttpError.new("API error"))
        end

        it "raises a Trs::Client::HttpError" do
          expect { described_class.call(trainee:) }.to raise_error(Client::HttpError)
        end
      end
    end
  end
end
