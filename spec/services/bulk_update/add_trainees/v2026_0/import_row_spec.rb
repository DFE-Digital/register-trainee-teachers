# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module AddTrainees
    RSpec.describe V20260::ImportRow do
      before do
        stub_const("BulkUpdate::AddTrainees::Config::VERSION", "v2026.0")
        stub_const("BulkUpdate::AddTrainees::VERSION", BulkUpdate::AddTrainees::V20260)
        create(
          :subject_specialism,
          allocation_subject: allocation_subject,
          name: "primary teaching",
        )
        create(
          :funding_method_subject,
          funding_method: undergrad_funding_rule,
          allocation_subject: allocation_subject,
        )
        create(
          :funding_method_subject,
          funding_method: school_direct_funding_rule,
          allocation_subject: allocation_subject,
        )
      end

      let(:current_provider) { create(:provider) }
      let(:csv) { Rails.root.join("spec/fixtures/files/bulk_update/trainee_uploads/v2026_0/five_trainees.csv").read }
      let(:parsed_csv) { CSV.parse(csv, headers: true) }
      let!(:nationality) { create(:nationality, :british) }
      let(:academic_cycle) { AcademicCycle.for_year(2024) || create(:academic_cycle, cycle_year: 2024) }
      let(:allocation_subject) { create(:allocation_subject) }
      let(:undergrad_funding_rule) do
        create(
          :funding_method,
          training_route: :provider_led_undergrad,
          funding_type: :scholarship,
          academic_cycle: academic_cycle,
        )
      end
      let(:school_direct_funding_rule) do
        create(
          :funding_method,
          training_route: :school_direct_salaried,
          funding_type: :scholarship,
          academic_cycle: academic_cycle,
        )
      end

      describe "#call" do
        let(:result) { described_class.call(row:, current_provider:) }

        context "when the row is invalid" do
          let(:csv) { Rails.root.join("spec/fixtures/files/bulk_update/trainee_uploads/v2026_0/five_trainees_with_failed.csv").read }
          let(:row) { parsed_csv[3] }

          it "does not create a trainee record" do
            expect { result }.not_to change { Trainee.count }

            expect(result.success).to be(false)
            expect(result.error_type).to eq(:validation)
          end
        end

        context "when the row is invalid with customised field names" do
          let(:csv) { Rails.root.join("spec/fixtures/files/bulk_update/trainee_uploads/v2026_0/five_trainees_with_three_errors.csv").read }
          let(:row) { parsed_csv[0] }

          it "does not create a trainee record" do
            expect { result }.not_to change { Trainee.count }

            expect(result.success).to be(false)
            expect(result.error_type).to eq(:validation)

            expect(result.errors).to include("Degree graduation year Enter a valid graduation year")
            expect(result.errors).to include("Degree graduation year Enter a year that is in the past, for example 2014")
            expect(result.errors).to include("Degree grade must be entered if specifying a previous UK degree or non-UK degree")
            expect(result.errors).to include("ITT Start Date can't be blank")
            expect(result.errors).to include("Date of Birth can't be blank")
            expect(result.errors).to include(/ITT Aim has invalid reference data value of '.*'/)
            expect(result.errors).to include(/Qualification Aim has invalid reference data value of '.*'/)
          end
        end

        context "when the row is a duplicate" do
          let(:csv) { Rails.root.join("spec/fixtures/files/bulk_update/trainee_uploads/v2026_0/five_trainees.csv").read }
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

          let!(:training_partner) { create(:training_partner, :scitt, urn: nil) }

          it "creates a trainee record without a training partner" do
            expect { result }.to change { Trainee.count }.by(1)

            expect(result.success).to be(true)
            expect(Trainee.last.training_partner).to be_nil
          end

          it "the record source is set to `CSV`" do
            expect { result }.to change { Trainee.count }.by(1)

            expect(Trainee.last.record_source).to eq(Trainee::CSV_SOURCE)
          end
        end

        context "when the row is valid and includes placement data" do
          let(:csv) { Rails.root.join("spec/fixtures/files/bulk_update/trainee_uploads/v2026_0/five_trainees_with_placement.csv").read }

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
          let(:csv) { Rails.root.join("spec/fixtures/files/bulk_update/trainee_uploads/v2026_0/five_trainees_with_degree.csv").read }
          let(:row) { parsed_csv.first }

          it "creates a trainee and a degree record" do
            expect { result }.to change { Trainee.count }.by(1)

            expect(result.success).to be(true)
            expect(Trainee.last.placements.count).to eq(0)
            expect(Trainee.last.degrees.count).to eq(1)
          end
        end

        context "when the row is valid and includes disabilities data" do
          let(:csv) { Rails.root.join("spec/fixtures/files/bulk_update/trainee_uploads/v2026_0/five_trainees_with_disability.csv").read }
          let(:row) { parsed_csv[0] }

          before do
            %i[
              deaf
              blind
              development_condition
              learning_difficulty
              long_standing_illness
              mental_health_condition
              physical_disability_or_mobility_issue
              social_or_communication_impairment
              other
            ].each { |name| create(:disability, name) }
          end

          it "creates a trainee and 9 disability records" do
            expect { result }.to change { Trainee.count }.by(1)

            expect(result.success).to be(true)

            trainee = Trainee.last

            expect(trainee.disabilities.count).to eq(9)

            Disability.pluck(:name).each do |name|
              expect(trainee.disabilities.exists?(name:)).to be(true)
            end
          end
        end
      end
    end
  end
end
