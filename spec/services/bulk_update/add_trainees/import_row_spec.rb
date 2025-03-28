# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module AddTrainees
    RSpec.describe ImportRow do
      let(:current_provider) { create(:provider) }
      let(:csv) { Rails.root.join("spec/fixtures/files/bulk_update/trainee_uploads/five_trainees.csv").read }
      let(:parsed_csv) { CSV.parse(csv, headers: true) }
      let!(:nationality) { create(:nationality, :british) }

      describe "#call" do
        let(:result) { described_class.call(row:, current_provider:) }

        context "when the row is invalid" do
          let(:csv) { Rails.root.join("spec/fixtures/files/bulk_update/trainee_uploads/five_trainees_with_two_failed.csv").read }
          let(:row) { parsed_csv[3] }

          it "does not create a trainee record" do
            expect { result }.not_to change { Trainee.count }

            expect(result.success).to be(false)
            expect(result.error_type).to eq(:validation)
          end
        end

        context "when the row is invalid with customised field names" do
          let(:csv) { Rails.root.join("spec/fixtures/files/bulk_update/trainee_uploads/five_trainees_with_three_errors.csv").read }
          let(:row) { parsed_csv[0] }

          it "does not create a trainee record" do
            expect { result }.not_to change { Trainee.count }

            expect(result.success).to be(false)
            expect(result.error_type).to eq(:validation)
            expect(result.errors[:errors]).to include("ITT Start Date can't be blank")
            expect(result.errors[:errors]).to include("Date of Birth can't be blank")
          end
        end

        context "when the row is a duplicate" do
          let(:csv) { Rails.root.join("spec/fixtures/files/bulk_update/trainee_uploads/five_trainees.csv").read }
          let(:row) { parsed_csv.first }

          before { described_class.call(row:, current_provider:) }

          it "does not create a trainee record" do
            expect { result }.not_to change { Trainee.count }

            expect(result.success).to be(false)
            expect(result.error_type).to eq(:duplicate)
            expect(result.errors).to eq(["This trainee is already in Register"])
          end
        end

        context "when the row is valid and does NOT include placement or degree data" do
          let(:row) { parsed_csv.first }

          let!(:lead_partner) { create(:lead_partner, :scitt, urn: nil) }

          it "creates a trainee record without a lead partner" do
            expect { result }.to change { Trainee.count }.by(1)

            expect(result.success).to be(true)
            expect(Trainee.last.lead_partner).to be_nil
          end

          it "the record source is set to `CSV`" do
            expect { result }.to change { Trainee.count }.by(1)

            expect(Trainee.last.record_source).to eq(Trainee::CSV_SOURCE)
          end
        end

        context "when the row is valid and includes placement data" do
          let(:csv) { Rails.root.join("spec/fixtures/files/bulk_update/trainee_uploads/five_trainees_with_placement.csv").read }

          context "with a single placement" do
            let(:row) { parsed_csv[-1] }

            it "creates a trainee and a placement record" do
              expect { result }.to change { Trainee.count }.by(1)

              expect(result.success).to be(true)

              placements = Trainee.last.placements

              expect(placements.count).to eq(1)

              placement = placements.last

              expect(placement.name).to eq("Placement 1")
              expect(placement.urn).to eq("773124")

              expect(Trainee.last.degrees.count).to eq(0)
            end
          end

          context "with multiple placements" do
            let(:row) { parsed_csv[0] }

            it "creates a trainee and three placement record" do
              expect { result }.to change { Trainee.count }.by(1)

              expect(result.success).to be(true)

              placements = Trainee.last.placements
              expect(placements.count).to eq(3)

              placement1, placement2, placement3 = placements

              expect(placement1.name).to eq("Placement 1")
              expect(placement1.urn).to eq("609384")

              expect(placement2.name).to eq("Placement 2")
              expect(placement2.urn).to eq("325900")

              expect(placement3.name).to eq("Placement 3")
              expect(placement3.urn).to eq("894261")

              expect(Trainee.last.degrees.count).to eq(0)
            end
          end
        end

        context "when the row is valid and includes degree data" do
          let(:csv) { Rails.root.join("spec/fixtures/files/bulk_update/trainee_uploads/five_trainees_with_degree.csv").read }
          let(:row) { parsed_csv.first }

          it "creates a trainee and a degree record" do
            expect { result }.to change { Trainee.count }.by(1)

            expect(result.success).to be(true)
            expect(Trainee.last.placements.count).to eq(0)
            expect(Trainee.last.degrees.count).to eq(1)
          end
        end
      end
    end
  end
end
