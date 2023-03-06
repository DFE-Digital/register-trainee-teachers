# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module RecommendationsUploads
    describe ValidateCsvRow do
      subject(:service) { described_class.new(row) }

      context "When row is valid" do
        let(:row) do
          {
            "trn" => "1234567",
            "heas id" => "12345678912345678",
            "provider trainee id" => "1234567",
            "last names" => "Blobby",
            "first names" => "Russell",
            "lead school" => "Bluemeadow High",
            "qts or eyts" => "QTS",
            "route" => "Early years (salaried)",
            "phase" => "Early years",
            "age range" => "0 to 5",
            "subject" => "Early years teaching",
            "date qts or eyts standards met" => Date.yesterday,
          }
        end

        describe "#valid?" do
          it { expect(service.valid?).to be true }
        end

        describe "messages" do
          it { expect(service.messages).to eql [] }
        end
      end

      context "When row is invalid" do
        let(:row) do
          {
            "trn" => "123567",
            "heas id" => "1234568912345678",
            "provider trainee id" => "1234",
            "last names" => "Blobby",
            "first names" => "Russell",
            "lead school" => "Bluemeadow High",
            "qts or eyts" => "QTS",
            "route" => "Early years (salaried)",
            "phase" => "Early years",
            "age range" => "0 to 5",
            "subject" => "Early years teaching",
            "date qts or eyts standards met" => "df",
          }
        end

        describe "#valid?" do
          it { expect(service.valid?).to be false }
        end

        describe "messages" do
          it do
            expect(service.messages).to eql(
              [
                "TRN must be 7 characters long and contain only numbers",
                "HESA ID must be 17 characters long and contain only numbers",
                "Date could not be parsed, please use the format dd/mm/yyyy e.g. 27/02/2022",
              ],
            )
          end
        end
      end
    end
  end
end
