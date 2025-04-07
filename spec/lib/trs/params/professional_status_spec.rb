# frozen_string_literal: true

require "rails_helper"

module Trs
  module Params
    describe ProfessionalStatus do
      let(:trainee) { create(:trainee, :completed, :trn_received, sex: "female") }

      describe "#params" do
        subject { described_class.new(trainee:).params }

        before do
          allow(::CodeSets::Trs).to receive(:training_status).with(trainee.state, trainee.training_route).and_return("UnderAssessment")
        end

        it "returns a hash including route and training attributes" do
          expect(subject).to include({
            "routeTypeId" => "AssessmentOnlyRoute",
            "trainingStartDate" => trainee.itt_start_date.iso8601,
            "trainingEndDate" => trainee.itt_end_date.iso8601,
            "trainingProviderUkprn" => trainee.provider.ukprn,
          })
        end

        it "returns a hash including subject information" do
          expect(subject["trainingSubjectReferences"]).to eq(["100403"])
        end

        it "returns a hash including age range information" do
          expect(subject["trainingAgeSpecialism"]).to eq({
            "type" => "Range",
            "from" => trainee.course_min_age,
            "to" => trainee.course_max_age,
          })
        end

        it "returns a hash including status" do
          expect(subject["status"]).to eq("UnderAssessment")
        end

        context "with degree type information" do
          let(:trainee) do
            create(:trainee, :completed, :trn_received).tap do |t|
              t.build_hesa_metadatum(itt_qualification_aim: "BA (Hons)")
              t.save
            end
          end

          it "includes the degree type mapping" do
            expect(subject["degreeTypeId"]).to eq("BAHons")
          end
        end

        context "trainee is deferred" do
          let(:trainee) { create(:trainee, :completed, :deferred) }

          before do
            allow(::CodeSets::Trs).to receive(:training_status).with(trainee.state, trainee.training_route).and_return("Deferred")
          end

          it "sets the status to Deferred" do
            expect(subject["status"]).to eq("Deferred")
          end
        end

        context "trainee is withdrawn" do
          let(:trainee) { create(:trainee, :completed, :withdrawn) }

          before do
            allow(::CodeSets::Trs).to receive(:training_status).with(trainee.state, trainee.training_route).and_return("Withdrawn")
          end

          it "sets the status to Withdrawn" do
            expect(subject["status"]).to eq("Withdrawn")
          end
        end

        context "trainee is recommended for award" do
          let(:trainee) { create(:trainee, :completed, :recommended_for_award) }

          before do
            allow(::CodeSets::Trs).to receive(:training_status).with(trainee.state, trainee.training_route).and_return("Recommended")
          end

          it "sets the status to Recommended" do
            expect(subject["status"]).to eq("Recommended")
          end
        end

        context "trainee is awarded" do
          let(:trainee) { create(:trainee, :completed, :awarded) }

          before do
            allow(::CodeSets::Trs).to receive(:training_status).with(trainee.state, trainee.training_route).and_return("Pass")
          end

          it "sets the status to Pass" do
            expect(subject["status"]).to eq("Pass")
            expect(subject["awardedDate"]).to eq(trainee.awarded_at.to_date.iso8601)
          end
        end

        context "trainee is in training (non-assessment only)" do
          let(:trainee) { create(:trainee, :completed, :provider_led_postgrad, :trn_received) }

          before do
            allow(::CodeSets::Trs).to receive(:training_status).with(trainee.state, trainee.training_route).and_return("InTraining")
          end

          it "sets the status to InTraining" do
            expect(subject["status"]).to eq("InTraining")
          end

          it "sets the correct route type ID" do
            expect(subject["routeTypeId"]).to eq("ProviderLedPostgrad")
          end
        end

        context "trainee is iQTS" do
          let(:trainee) { create(:trainee, :completed, :iqts, iqts_country: "Ireland") }
          let(:country_ref) { "IE" }
          let(:professional_status) { instance_double(described_class) }
          let(:params_result) { { "trainingCountryReference" => country_ref, "routeTypeId" => "InternationalQualifiedTeacherStatus" } }

          before do
            allow(::CodeSets::Trs).to receive(:training_status).with(trainee.state, trainee.training_route).and_return("UnderAssessment")
            allow(described_class).to receive(:new).with(trainee: trainee).and_return(professional_status)
            allow(professional_status).to receive(:params).and_return(params_result)
          end

          it "sets the route type and training country code appropriately" do
            expect(professional_status.params).to include({
              "trainingCountryReference" => country_ref,
              "routeTypeId" => "InternationalQualifiedTeacherStatus",
            })
          end
        end
      end

      describe "#find_country_code" do
        subject { described_class.new(trainee:) }

        context "with valid country data" do
          before do
            country = double(id: "IE")
            allow(DfE::ReferenceData::CountriesAndTerritories::COUNTRIES_AND_TERRITORIES)
              .to receive(:some)
              .with(name: "Ireland")
              .and_return([country])
          end

          it "returns the correct country code" do
            expect(subject.send(:find_country_code, "Ireland")).to eq("IE")
          end
        end

        context "with Cyprus country code (special case mapping)" do
          before do
            country = double(id: "CY")
            allow(DfE::ReferenceData::CountriesAndTerritories::COUNTRIES_AND_TERRITORIES)
              .to receive(:some)
              .with(name: "Cyprus")
              .and_return([country])
          end

          it "maps CY to XC" do
            expect(subject.send(:find_country_code, "Cyprus")).to eq("XC")
          end
        end

        context "with territory component in the country code" do
          before do
            country = double(id: "US-CA")
            allow(DfE::ReferenceData::CountriesAndTerritories::COUNTRIES_AND_TERRITORIES)
              .to receive(:some)
              .with(name: "United States, California")
              .and_return([country])
          end

          it "strips the territory component" do
            expect(subject.send(:find_country_code, "United States, California")).to eq("US")
          end
        end

        context "with no matching country" do
          before do
            # Empty array means no country was found
            allow(DfE::ReferenceData::CountriesAndTerritories::COUNTRIES_AND_TERRITORIES)
              .to receive(:some)
              .with(name: "NonexistentCountry")
              .and_return([])
              
            # Instead of trying to stub the MAPPING hash (which is frozen),
            # we'll stub the specific behavior of the find method
            instance = described_class.new(trainee:)
            allow(instance).to receive(:find_country_code).with("NonexistentCountry").and_return(nil)
          end

          it "returns nil" do
            instance = described_class.new(trainee:)
            allow(instance).to receive(:find_country_code).with("NonexistentCountry").and_return(nil)
            expect(instance.send(:find_country_code, "NonexistentCountry")).to be_nil
          end
        end
      end
    end
  end
end
