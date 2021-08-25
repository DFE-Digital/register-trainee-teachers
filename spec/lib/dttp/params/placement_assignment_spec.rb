# frozen_string_literal: true

require "rails_helper"

module Dttp
  module Params
    describe PlacementAssignment do
      let(:time_now_in_zone) { Time.zone.now }
      let(:degree) { build(:degree, :uk_degree_with_details) }
      let(:provider) { create(:provider, dttp_id: dttp_provider_id) }
      let(:trainee) do
        create(:trainee, :with_course_details, :with_start_date, course_start_date: Date.parse("10/10/2020"), dttp_id: dttp_contact_id, provider: provider)
      end

      let(:contact_change_set_id) { SecureRandom.uuid }
      let(:dttp_contact_id) { SecureRandom.uuid }
      let(:dttp_age_range_entity_id) { SecureRandom.uuid }
      let(:dttp_ey_age_range_entity_id) { SecureRandom.uuid }
      let(:dttp_course_subject_entity_id) { SecureRandom.uuid }
      let(:dttp_ey_subject_entity_id) { SecureRandom.uuid }
      let(:dttp_degree_subject_entity_id) { SecureRandom.uuid }
      let(:dttp_degree_institution_entity_id) { SecureRandom.uuid }
      let(:dttp_degree_grade_entity_id) { SecureRandom.uuid }
      let(:dttp_country_entity_id) { SecureRandom.uuid }
      let(:dttp_provider_id) { SecureRandom.uuid }
      let(:dttp_lead_school_id) { SecureRandom.uuid }
      let(:dttp_employing_school_id) { SecureRandom.uuid }
      let(:dttp_route_id) { Dttp::CodeSets::Routes::MAPPING[trainee.training_route][:entity_id] }
      let(:dttp_qualification_aim_id) { Dttp::CodeSets::QualificationAims::MAPPING[trainee.training_route][:entity_id] }
      let(:dttp_training_initiative_entity_id) { SecureRandom.uuid }

      before do
        allow(Time).to receive(:now).and_return(time_now_in_zone)

        trainee.degrees << degree

        stub_const("Dttp::CodeSets::AgeRanges::MAPPING",
                   { trainee.course_age_range => { entity_id: dttp_age_range_entity_id } })
        stub_const("Dttp::CodeSets::DegreeSubjects::MAPPING",
                   { degree.subject => { entity_id: dttp_degree_subject_entity_id } })
        stub_const("Dttp::CodeSets::Institutions::MAPPING",
                   { degree.institution => { entity_id: dttp_degree_institution_entity_id } })
        stub_const("Dttp::CodeSets::Grades::MAPPING",
                   { degree.grade => { entity_id: dttp_degree_grade_entity_id } })
        stub_const("Dttp::CodeSets::Countries::MAPPING",
                   { degree.country => { entity_id: dttp_country_entity_id } })
      end

      subject { described_class.new(trainee, contact_change_set_id).params }

      describe "#params" do
        describe "academic year" do
          let(:trainee) { create(:trainee, :with_course_details, :with_start_date, course_start_date: Date.parse(start_date)) }
          let(:expected_value) { "/dfe_academicyears(#{expected_year})" }

          subject do
            super()["dfe_AcademicYearId@odata.bind"]
          end

          context "trainee with course in 20/21" do
            let(:expected_year) { Dttp::Params::PlacementAssignment::ACADEMIC_YEAR_2020_2021 }

            context "1/8/2020" do
              let(:start_date) { "1/8/2020" }

              it { is_expected.to eq(expected_value) }
            end

            context "31/7/2021" do
              let(:start_date) { "31/7/2021" }

              it { is_expected.to eq(expected_value) }
            end
          end

          context "trainee with course in 21/22" do
            let(:expected_year) { Dttp::Params::PlacementAssignment::ACADEMIC_YEAR_2021_2022 }

            context "1/8/2021" do
              let(:start_date) { "1/8/2021" }

              it { is_expected.to eq(expected_value) }
            end

            context "31/7/2022" do
              let(:start_date) { "31/7/2022" }

              it { is_expected.to eq(expected_value) }
            end
          end

          context "trainee with course in 22/23" do
            let(:expected_year) { Dttp::Params::PlacementAssignment::ACADEMIC_YEAR_2022_2023 }

            context "1/8/2022" do
              let(:start_date) { "1/8/2022" }

              it { is_expected.to eq(expected_value) }
            end

            context "31/7/2023" do
              let(:start_date) { "31/7/2023" }

              it { is_expected.to eq(expected_value) }
            end
          end
        end

        context "degrees" do
          before do
            stub_const(
              "Dttp::CodeSets::CourseSubjects::MAPPING",
              { trainee.course_subject_one => { entity_id: dttp_course_subject_entity_id } },
            )
          end

          context "UK degree" do
            it "returns a hash with all the UK specific placement assignment fields " do
              expect(subject).to eq({
                "dfe_programmestartdate" => trainee.course_start_date.in_time_zone.iso8601,
                "dfe_programmeenddate" => trainee.course_end_date.in_time_zone.iso8601,
                "dfe_ContactId@odata.bind" => "$#{contact_change_set_id}",
                "dfe_CoursePhaseId@odata.bind" => "/dfe_coursephases(#{dttp_age_range_entity_id})",
                "dfe_ITTSubject1Id@odata.bind" => "/dfe_subjects(#{dttp_course_subject_entity_id})",
                "dfe_SubjectofUGDegreeId@odata.bind" => "/dfe_jacses(#{dttp_degree_subject_entity_id})",
                "dfe_commencementdate" => trainee.commencement_date.in_time_zone.iso8601,
                "dfe_AwardingInstitutionId@odata.bind" => "/accounts(#{dttp_degree_institution_entity_id})",
                "dfe_ClassofUGDegreeId@odata.bind" => "/dfe_classofdegrees(#{dttp_degree_grade_entity_id})",
                "dfe_traineeid" => trainee.trainee_id,
                "dfe_AcademicYearId@odata.bind" => "/dfe_academicyears(#{Dttp::Params::PlacementAssignment::ACADEMIC_YEAR_2020_2021})",
                "dfe_courselevel" => Dttp::Params::PlacementAssignment::COURSE_LEVEL_PG,
                "dfe_sendforregistration" => true,
                "dfe_ProviderId@odata.bind" => "/accounts(#{dttp_provider_id})",
                "dfe_ITTQualificationAimId@odata.bind" => "/dfe_ittqualificationaims(#{dttp_qualification_aim_id})",
                "dfe_programmeyear" => 1,
                "dfe_programmelength" => 1,
                "dfe_RouteId@odata.bind" => "/dfe_routes(#{dttp_route_id})",
                "dfe_undergraddegreedateobtained" => Date.parse("01-01-#{degree.graduation_year}").to_datetime.iso8601,
              })
            end
          end

          context "Non-UK degree" do
            let(:degree) { build(:degree, :non_uk_degree_with_details) }

            it "returns a hash with all the Non-UK specific placement assignment fields" do
              expect(subject).to eq({
                "dfe_programmestartdate" => trainee.course_start_date.in_time_zone.iso8601,
                "dfe_programmeenddate" => trainee.course_end_date.in_time_zone.iso8601,
                "dfe_ContactId@odata.bind" => "$#{contact_change_set_id}",
                "dfe_CoursePhaseId@odata.bind" => "/dfe_coursephases(#{dttp_age_range_entity_id})",
                "dfe_ITTSubject1Id@odata.bind" => "/dfe_subjects(#{dttp_course_subject_entity_id})",
                "dfe_SubjectofUGDegreeId@odata.bind" => "/dfe_jacses(#{dttp_degree_subject_entity_id})",
                "dfe_commencementdate" => trainee.commencement_date.in_time_zone.iso8601,
                "dfe_CountryofStudyId@odata.bind" => "/dfe_countries(#{dttp_country_entity_id})",
                "dfe_traineeid" => trainee.trainee_id,
                "dfe_AcademicYearId@odata.bind" => "/dfe_academicyears(#{Dttp::Params::PlacementAssignment::ACADEMIC_YEAR_2020_2021})",
                "dfe_courselevel" => Dttp::Params::PlacementAssignment::COURSE_LEVEL_PG,
                "dfe_sendforregistration" => true,
                "dfe_ProviderId@odata.bind" => "/accounts(#{dttp_provider_id})",
                "dfe_ITTQualificationAimId@odata.bind" => "/dfe_ittqualificationaims(#{dttp_qualification_aim_id})",
                "dfe_programmeyear" => 1,
                "dfe_programmelength" => 1,
                "dfe_RouteId@odata.bind" => "/dfe_routes(#{dttp_route_id})",
                "dfe_undergraddegreedateobtained" => Date.parse("01-01-#{degree.graduation_year}").to_datetime.iso8601,
              })
            end
          end
        end

        context "No contact_change_set_id passed" do
          subject { described_class.new(trainee).params }

          it "doesn't include contact id" do
            expect(subject).not_to include(
              { "dfe_ContactId@odata.bind" => "$#{contact_change_set_id}" },
            )
          end
        end

        context "Future Teaching Scholars route" do
          context "with a trainee on the future_teaching_scholars initiative" do
            let(:future_teaching_scholars) { ROUTE_INITIATIVES_ENUMS[:future_teaching_scholars] }
            let(:dttp_fts_route_id) { Dttp::CodeSets::Routes::MAPPING[future_teaching_scholars][:entity_id] }

            let(:trainee) do
              create(
                :trainee,
                :with_course_details,
                :with_start_date,
                dttp_id: dttp_contact_id,
                provider: provider,
                training_initiative: future_teaching_scholars,
              )
            end

            it "sends the training initiative as a DTTP route" do
              expect(subject["dfe_RouteId@odata.bind"]).to eq "/dfe_routes(#{dttp_fts_route_id})"
            end
          end
        end

        context "subjects" do
          let(:trainee) do
            create(
              :trainee,
              :with_course_details,
              :with_start_date,
              dttp_id: dttp_contact_id,
              provider: provider,
              course_subject_one: CourseSubjects::BIOLOGY,
              course_subject_two: CourseSubjects::CHEMISTRY,
              course_subject_three: CourseSubjects::MATHEMATICS,
            )
          end

          subject { described_class.new(trainee).params }

          it "sets the dttp itt subject params for all given subjects" do
            expect(subject).to include({
              "dfe_ITTSubject1Id@odata.bind" => "/dfe_subjects(#{CodeSets::CourseSubjects::MAPPING[CourseSubjects::BIOLOGY][:entity_id]})",
              "dfe_ITTSubject2Id@odata.bind" => "/dfe_subjects(#{CodeSets::CourseSubjects::MAPPING[CourseSubjects::CHEMISTRY][:entity_id]})",
              "dfe_ITTSubject3Id@odata.bind" => "/dfe_subjects(#{CodeSets::CourseSubjects::MAPPING[CourseSubjects::MATHEMATICS][:entity_id]})",
            })
          end
        end

        context "trainee has no trainee_id" do
          let(:trainee) do
            create(:trainee, :with_course_details, :with_start_date,
                   dttp_id: dttp_contact_id, provider: provider, trainee_id: nil)
          end

          it "passes NOTPROVIDED for dfe_traineeid" do
            expect(subject).to include(
              { "dfe_traineeid" => "NOTPROVIDED" },
            )
          end
        end

        context "Early years undergrad" do
          let(:trainee) do
            create(:trainee, :early_years_undergrad, :with_course_details, :with_start_date,
                   dttp_id: dttp_contact_id, provider: provider)
          end

          subject { described_class.new(trainee).params }

          before do
            stub_const("Dttp::CodeSets::AgeRanges::MAPPING", { AgeRange::ZERO_TO_FIVE => { entity_id: dttp_ey_age_range_entity_id } })
            trainee.set_early_years_course_details
          end

          it "returns a hash including the undergrad course level" do
            expect(subject).to include(
              { "dfe_courselevel" => Dttp::Params::PlacementAssignment::COURSE_LEVEL_UG },
            )
          end
        end

        context "school direct (tuition fee)" do
          let(:trainee) do
            create(:trainee,
                   :school_direct_tuition_fee,
                   :with_course_details,
                   :with_start_date,
                   :with_lead_school,
                   dttp_id: dttp_contact_id,
                   provider: provider)
          end

          context "with a valid school" do
            before do
              create(:dttp_school, :active, dttp_id: dttp_lead_school_id, urn: trainee.lead_school.urn)
            end

            subject { described_class.new(trainee).params }

            it "sets the lead school DTTP param" do
              expect(subject).to include({
                "dfe_LeadSchoolId@odata.bind" => "/accounts(#{dttp_lead_school_id})",
              })
            end
          end

          context "with an invalid school" do
            before do
              create(:dttp_school)
            end

            it "raises an active record error" do
              expect { described_class.new(trainee).params }.to raise_error(ActiveRecord::RecordNotFound)
            end
          end
        end

        context "school direct (salaried)" do
          let(:trainee) do
            create(:trainee,
                   :school_direct_salaried,
                   :with_course_details,
                   :with_start_date,
                   :with_lead_school,
                   :with_employing_school,
                   dttp_id: dttp_contact_id,
                   provider: provider)
          end

          before do
            create(:dttp_school, :active, dttp_id: dttp_lead_school_id, urn: trainee.lead_school.urn)
            create(:dttp_school, :active, dttp_id: dttp_employing_school_id, urn: trainee.employing_school.urn)
          end

          subject { described_class.new(trainee).params }

          it "sets the lead and employing school DTTP params" do
            expect(subject).to include({
              "dfe_LeadSchoolId@odata.bind" => "/accounts(#{dttp_lead_school_id})",
              "dfe_EmployingSchoolId@odata.bind" => "/accounts(#{dttp_employing_school_id})",
            })
          end
        end

        context "bursary details", feature_show_funding: true do
          let(:dttp_bursary_details_entity_id) { SecureRandom.uuid }
          let(:dttp_funding_band_entity_id) { SecureRandom.uuid }

          before do
            stub_const(
              "Dttp::CodeSets::BursaryDetails::MAPPING",
              { trainee.training_route => { entity_id: dttp_bursary_details_entity_id } },
            )
            stub_const(
              "Dttp::CodeSets::FundingBands::MAPPING",
              { trainee.bursary_tier => { entity_id: dttp_funding_band_entity_id } },
            )
          end

          context "when the send_funding_to_dttp feature flag is off" do
            it "doesn't send bursary details" do
              expect(subject.keys).not_to include("dfe_ITTFundingBandId@odata.bind")
              expect(subject.keys).not_to include("dfe_BursaryDetailsId@odata.bind")
              expect(subject.keys).not_to include("dfe_allocatedplace")
            end
          end

          context "when the send_funding_to_dttp feature flag is on", feature_send_funding_to_dttp: true do
            context "and the trainee is not applying for a bursary" do
              it "sends the correct params" do
                expect(subject).to include({ "dfe_allocatedplace" => 2 })
                expect(subject.keys).not_to include("dfe_ITTFundingBandId@odata.bind")
                expect(subject.keys).not_to include("dfe_BursaryDetailsId@odata.bind")
              end
            end

            context "and the trainee is applying for a tiered bursary" do
              let(:trainee) do
                create(
                  :trainee,
                  :with_course_details,
                  :with_start_date,
                  :with_tiered_bursary,
                  dttp_id: dttp_contact_id,
                )
              end

              it "sends the correct params" do
                expect(subject).to include({ "dfe_allocatedplace" => 1 })
                expect(subject).to include({
                  "dfe_ITTFundingBandId@odata.bind" => "/dfe_ittfundingbands(#{dttp_funding_band_entity_id})",
                })
                expect(subject.keys).not_to include("dfe_BursaryDetailsId@odata.bind")
              end
            end

            context "and the trainee is applying for a subject-related bursary" do
              let(:trainee) do
                create(
                  :trainee,
                  :with_course_details,
                  :with_start_date,
                  :with_provider_led_bursary,
                  dttp_id: dttp_contact_id,
                )
              end

              it "sends the correct params" do
                expect(subject).to include({ "dfe_allocatedplace" => 1 })
                expect(subject.keys).not_to include("dfe_ITTFundingBandId@odata.bind")
                expect(subject).to include({
                  "dfe_BursaryDetailsId@odata.bind" => "/dfe_bursarydetails(#{dttp_bursary_details_entity_id})",
                })
              end
            end
          end
        end

        context "training initiative", feature_show_funding: true do
          before do
            stub_const(
              "Dttp::CodeSets::TrainingInitiatives::MAPPING",
              { trainee.training_initiative => { entity_id: dttp_training_initiative_entity_id } },
            )
          end

          context "but the send_funding_to_dttp feature flag is off" do
            it "doesn't send an initiative" do
              expect(subject.keys).not_to include("dfe_Initiative1Id@odata.bind")
            end
          end

          context "and the send_funding_to_dttp feature flag is on", feature_send_funding_to_dttp: true do
            context "but the trainee has no initiative" do
              let(:trainee) do
                create(
                  :trainee,
                  :with_course_details,
                  :with_start_date,
                  dttp_id: dttp_contact_id,
                  training_initiative: ROUTE_INITIATIVES_ENUMS[:no_initiative],
                )
              end

              it "doesn't send the initiative" do
                expect(subject).not_to include({
                  "dfe_Initiative1Id@odata.bind" => "/dfe_initiatives(#{dttp_training_initiative_entity_id})",
                })
              end
            end

            context "but the trainee in on an initiative not recognised by DTTP" do
              let(:trainee) do
                create(
                  :trainee,
                  :with_course_details,
                  :with_start_date,
                  dttp_id: dttp_contact_id,
                  training_initiative: ROUTE_INITIATIVES_ENUMS[:future_teaching_scholars],
                )
              end

              it "doesn't send the initiative" do
                expect(subject).not_to include({
                  "dfe_Initiative1Id@odata.bind" => "/dfe_initiatives(#{dttp_training_initiative_entity_id})",
                })
              end
            end

            context "and the trainee has an initiative recognised by DTTP" do
              let(:trainee) do
                create(
                  :trainee,
                  :with_course_details,
                  :with_start_date,
                  dttp_id: dttp_contact_id,
                  training_initiative: ROUTE_INITIATIVES_ENUMS[:now_teach],
                )
              end

              it "sends the initiative" do
                expect(subject).to include({
                  "dfe_Initiative1Id@odata.bind" => "/dfe_initiatives(#{dttp_training_initiative_entity_id})",
                })
              end
            end
          end
        end

        context "study_mode enabled", feature_course_study_mode: true do
          context "has study_mode set" do
            let(:trainee) do
              create(
                :trainee,
                :provider_led_postgrad,
                :with_course_details,
                :with_start_date,
                dttp_id: dttp_contact_id,
                provider: provider,
                study_mode: COURSE_STUDY_MODES[:full_time],
              )
            end

            subject { described_class.new(trainee).params }

            it "sets study_mode" do
              expect(subject).to include({
                "dfe_StudyModeId@odata.bind" => "/dfe_studymodeses(#{CodeSets::CourseStudyModes::MAPPING[COURSE_STUDY_MODES[:full_time]][:entity_id]})",
              })
            end
          end

          context "study_mode is not set" do
            let(:trainee) do
              create(
                :trainee,
                :early_years_assessment_only,
                :with_course_details,
                :with_start_date,
                dttp_id: dttp_contact_id,
                provider: provider,
                study_mode: nil,
              )
            end

            subject { described_class.new(trainee).params }

            it "does not set study_mode" do
              expect(subject.keys).not_to include("dfe_StudyModeId@odata.bind")
            end
          end
        end
      end
    end
  end
end
