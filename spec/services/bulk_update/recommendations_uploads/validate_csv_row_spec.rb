# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module RecommendationsUploads
    describe ValidateCsvRow do
      include RecommendationsUploadHelper

      subject(:service) { described_class.new(csv:, row:, trainee:) }

      let!(:trainee) { create(:trainee, :bulk_recommend, first_names: "DÁvìd") }
      let(:overwrite) { [] }
      let(:csv) { create_recommendations_upload_csv!(overwrite:) }
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
              "date qts or eyts requirement met" => Date.yesterday.strftime("%d/%m/%Y"),
            })
          end

          describe "#valid?" do
            it { expect(service.valid?).to be true }
          end

          describe "messages" do
            it { expect(service.messages).to eql [] }
          end
        end

        context "When date is invalid" do
          let(:row) do
            Row.new({
              "trn" => "1234567",
              "hesa id" => "12345678912345678",
              "provider trainee id" => "1234567",
              "date qts or eyts requirement met" => "21/85/2022",
            })
          end

          describe "#valid?" do
            it { expect(service.valid?).to be false }
          end

          describe "messages" do
            it { expect(service.messages).to eql ["Date QTS or EYTS requirement met must be a valid date"] }
          end
        end

        context "When row is invalid" do
          let(:row) do
            Row.new({
              "trn" => "123567", # invalid
              "hesa id" => "1234568912345678", # invalid
              "provider trainee id" => "1234",
              "date qts or eyts requirement met" => "not-a-date", # invalid
            })
          end

          describe "#valid?" do
            it { expect(service.valid?).to be false }
          end

          describe "messages" do
            it do
              expect(service.messages).to eql(
                [
                  "TRN must be 7 numbers",
                  "HESA ID must be 13 or 17 numbers",
                  "Date QTS or EYTS requirement met must be written as dd/mm/yyyy, for example 27/02/2023",
                ],
              )
            end
          end
        end

        context "When row is empty" do
          let(:row) do
            Row.new({})
          end

          describe "#valid?" do
            it { expect(service.valid?).to be true }
          end

          describe "messages" do
            it do
              expect(service.messages).to eql([])
            end
          end
        end

        context "When row contains blank strings" do
          let(:row) do
            Row.new({
              "trn" => "",
              "hesa id" => "",
              "provider trainee id" => "",
              "date qts or eyts requirement met" => "",
            })
          end

          describe "#valid?" do
            it { expect(service.valid?).to be true }
          end

          describe "messages" do
            it do
              expect(service.messages).to eql([])
            end
          end
        end
      end

      context "with a matched trainee" do
        # generate and overwrite dates within a BulkRecommendExport CSV
        let(:overwrite) do
          [
            { Reports::BulkRecommendReport::DATE => Time.zone.now.strftime("%d/%m/%Y") },
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
                "āsdfēsdö" # will force error each attribute but should not throw encoding issue with diacritics
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
                  "TRN must be 7 numbers",
                  "HESA ID must be 13 or 17 numbers",
                  "Date QTS or EYTS requirement met must be written as dd/mm/yyyy, for example 27/02/2023",
                  "TRN must match trainee record", "HESA ID must match trainee record",
                  "Provider trainee ID must match trainee record",
                  "First name must match trainee record",
                  "Last name must match trainee record",
                  "Lead partner must match trainee record",
                  "QTS or EYTS must match trainee record",
                  "Route must match trainee record",
                  "Phase must match trainee record",
                  "Age range must match trainee record",
                  "Subject must match trainee record"
                ],
              )
            end
          end
        end

        describe "award type" do
          let(:award_type_error) { "QTS or EYTS must match trainee record" }
          let(:report_award_type) { nil }
          let(:overwrite) do
            [
              { Reports::BulkRecommendReport::QTS_OR_EYTS => report_award_type },
            ]
          end

          let!(:trainee) { create(:trainee, :early_years_assessment_only) }

          context "doesn't match" do
            it "errors" do
              expect(service.messages).to include(award_type_error)
            end
          end

          context "matches but with differing case" do
            let!(:report_award_type) { "eyts" }

            it "does not error" do
              expect(service.messages).not_to include(award_type_error)
            end
          end
        end
      end

      context "when the row raises an exception" do
        before do
          allow(row).to receive(:trn).and_raise(StandardError)
        end

        it "returns the correct error message" do
          expect(service.messages).to eql(["An unexpected error occurred, please check the uploaded file and try again"])
        end
      end

      context "when removing accented characters raises an exception" do
        before do
          allow(I18n).to receive(:transliterate).and_raise(ArgumentError)
        end

        it "returns the correct error message" do
          expect(service.messages.first).to include("Error parsing text")
        end
      end
    end
  end
end
