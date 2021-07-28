# frozen_string_literal: true

require "rails_helper"

module Dttp
  module Params
    describe PlacementAssignment do
      let(:time_now_in_zone) { Time.zone.now }
      let(:degree) { build(:degree, :uk_degree_with_details) }
      let(:provider) { create(:provider, dttp_id: dttp_provider_id) }
      let(:trainee) do
        create(:trainee, :with_course_details, :with_start_date, dttp_id: dttp_contact_id, provider: provider)
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

        context "subjects" do
          let(:trainee) do
            create(
              :trainee,
              :with_course_details,
              :with_start_date,
              dttp_id: dttp_contact_id,
              provider: provider,
              course_subject_one: CodeSets::CourseSubjects::BIOLOGY,
              course_subject_two: CodeSets::CourseSubjects::CHEMISTRY,
              course_subject_three: CodeSets::CourseSubjects::MATHEMATICS,
            )
          end

          subject { described_class.new(trainee).params }

          it "sets the dttp itt subject params for all given subjects" do
            expect(subject).to include({
              "dfe_ITTSubject1Id@odata.bind" => "/dfe_subjects(#{CodeSets::CourseSubjects::MAPPING[CodeSets::CourseSubjects::BIOLOGY][:entity_id]})",
              "dfe_ITTSubject2Id@odata.bind" => "/dfe_subjects(#{CodeSets::CourseSubjects::MAPPING[CodeSets::CourseSubjects::CHEMISTRY][:entity_id]})",
              "dfe_ITTSubject3Id@odata.bind" => "/dfe_subjects(#{CodeSets::CourseSubjects::MAPPING[CodeSets::CourseSubjects::MATHEMATICS][:entity_id]})",
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

          before do
            create(:dttp_school, dttp_id: dttp_lead_school_id, urn: trainee.lead_school.urn)
          end

          subject { described_class.new(trainee).params }

          it "sets the lead school DTTP param" do
            expect(subject).to include({
              "dfe_LeadSchoolId@odata.bind" => "/accounts(#{dttp_lead_school_id})",
            })
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
            create(:dttp_school, dttp_id: dttp_lead_school_id, urn: trainee.lead_school.urn)
            create(:dttp_school, dttp_id: dttp_employing_school_id, urn: trainee.employing_school.urn)
          end

          subject { described_class.new(trainee).params }

          it "sets the lead and employing school DTTP params" do
            expect(subject).to include({
              "dfe_LeadSchoolId@odata.bind" => "/accounts(#{dttp_lead_school_id})",
              "dfe_EmployingSchoolId@odata.bind" => "/accounts(#{dttp_employing_school_id})",
            })
          end
        end

        context "funding", feature_show_funding: true do
          before do
            stub_const("Dttp::CodeSets::TrainingInitiatives::MAPPING", { trainee.training_initiative => { entity_id: dttp_training_initiative_entity_id } })
          end

          context "but the send_funding_to_dttp feature flag is off" do
            it "doesn't send funding information" do
              expect(subject).not_to include({
                "dfe_initiative1id_value" => "/dfe_initiatives(#{dttp_training_initiative_entity_id})",
              })
            end
          end

          context "and the send_funding_to_dttp feature flag is on", feature_send_funding_to_dttp: true do
            context "but the trainee has no initiative" do
              let(:trainee) do
                create(:trainee, :with_course_details, :with_start_date, dttp_id: dttp_contact_id, training_initiative: ROUTE_INITIATIVES_ENUMS[:no_initiative])
              end

              it "doesn't send funding information" do
                expect(subject).not_to include({
                  "dfe_initiative1id_value" => "/dfe_initiatives(#{dttp_training_initiative_entity_id})",
                })
              end
            end

            context "and the trainee has an initiative" do
              let(:trainee) do
                create(:trainee, :with_course_details, :with_start_date, dttp_id: dttp_contact_id, training_initiative: ROUTE_INITIATIVES_ENUMS[:future_teaching_scholars])
              end

              it "sends funding information" do
                expect(subject).to include({
                  "dfe_initiative1id_value" => "/dfe_initiatives(#{dttp_training_initiative_entity_id})",
                })
              end
            end
          end
        end
      end
    end
  end
end
