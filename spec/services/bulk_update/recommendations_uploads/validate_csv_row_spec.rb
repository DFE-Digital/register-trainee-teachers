# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module RecommendationsUploads
    describe ValidateCsvRow do
      include RecommendationsUploadHelper

      subject(:service) { described_class.new(csv:, row:, trainee:) }

      let!(:trainee) { create(:trainee, :bulk_recommend) }
      let(:overwrite) { [] }
      let(:csv) { recommendations_upload_csv(Trainee.all, overwrite) }
      let(:row) { Row.new(csv[1]) }

      context "without a matched trainee" do
        let!(:trainee) { nil }
        let(:csv) { nil }

        context "When row is valid" do
          let(:row) do
            Row.new({
              "trn" => "1234567",
              "hesa id" => "12345678912345678",
              "provider trainee id" => "1234567",
              "date qts or eyts standards met" => Date.yesterday.strftime("%d/%m/%Y"),
            })
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
            Row.new({
              "trn" => "123567", # invalid
              "hesa id" => "1234568912345678", # invalid
              "provider trainee id" => "1234",
              "date qts or eyts standards met" => "not-a-date", # invalid
            })
          end

          describe "#valid?" do
            it { expect(service.valid?).to be false }
          end

          describe "messages" do
            it do
              expect(service.messages).to eql(
                [
                  "TRN must be 7 characters long and contain only numbers",
                  "HESA ID must be 13 or 17 characters long and contain only numbers",
                  "Date could not be parsed, please use the format dd/mm/yyyy e.g. 27/02/2022",
                ],
              )
            end
          end
        end
      end

      context "with a matched trainee" do
        # generate and overwrite dates within a BulkRecommendExport CSV
        let(:overwrite) do
          [
            { Reports::BulkRecommendReport::DATE => Date.yesterday.strftime("%d/%m/%Y") },
          ]
        end

        context "When row is valid" do
          describe "#valid?" do
            it { expect(service.valid?).to be true }
          end

          describe "messages" do
            it { expect(service.messages).to eql [] }
          end
        end

        context "When row is invalid" do
          let(:overwrite) do
            [
              Reports::BulkRecommendReport::DEFAULT_HEADERS.map.index_with do
                "asdfsd" # will force error each attribute
              end,
            ]
          end

          let!(:trainee) { create(:trainee, :bulk_recommend_from_hesa) }

          describe "#valid?" do
            it { expect(service.valid?).to be false }
          end

          describe "messages" do
            it "is returns all expected error messages" do
              expect(service.messages).to eql(
                [
                  "TRN must be 7 characters long and contain only numbers",
                  "HESA ID must be 13 or 17 characters long and contain only numbers",
                  "Date could not be parsed, please use the format dd/mm/yyyy e.g. 27/02/2022",
                  "Trainee TRN does not match",
                  "Trainee HESA ID does not match",
                  "Provider trainee id does not match",
                  "Trainee first names do not match",
                  "Trainee last names do not match",
                  "Lead school does not match",
                  "QTS/EYTS declaration does not match",
                  "Route does not match",
                  "Phase does not match",
                  "Age range does not match",
                  "Subject does not match",
                ],
              )
            end
          end
        end
      end
    end
  end
end
