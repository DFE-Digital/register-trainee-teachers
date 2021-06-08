# frozen_string_literal: true

require "rails_helper"

module Dttp
  module Params
    describe PlacementAssignment do
      let(:time_now_in_zone) { Time.zone.now }
      let(:provider) { create(:provider, dttp_id: dttp_provider_id) }
      let(:trainee) do
        create(:trainee, :with_course_details, :with_start_date, dttp_id: dttp_contact_id, provider: provider)
      end

      let(:contact_change_set_id) { SecureRandom.uuid }
      let(:dttp_contact_id) { SecureRandom.uuid }
      let(:dttp_age_range_entity_id) { SecureRandom.uuid }
      let(:dttp_course_subject_entity_id) { SecureRandom.uuid }
      let(:dttp_degree_subject_entity_id) { SecureRandom.uuid }
      let(:dttp_degree_institution_entity_id) { SecureRandom.uuid }
      let(:dttp_degree_grade_entity_id) { SecureRandom.uuid }
      let(:dttp_country_entity_id) { SecureRandom.uuid }
      let(:dttp_provider_id) { SecureRandom.uuid }
      let(:dttp_lead_school_id) { SecureRandom.uuid }
      let(:dttp_employing_school_id) { SecureRandom.uuid }
      let(:dttp_route_id) { Dttp::CodeSets::Routes::MAPPING[trainee.training_route][:entity_id] }
      let(:dttp_qualification_aim_id) { Dttp::CodeSets::QualificationAims::MAPPING[trainee.training_route][:entity_id] }

      before do
        allow(Time).to receive(:now).and_return(time_now_in_zone)

        trainee.degrees << degree

        stub_const("Dttp::CodeSets::AgeRanges::MAPPING",
                   { trainee.course_age_range => { entity_id: dttp_age_range_entity_id } })
        stub_const("Dttp::CodeSets::CourseSubjects::MAPPING",
                   { trainee.subject => { entity_id: dttp_course_subject_entity_id } })
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

      let(:degree) { build(:degree, :uk_degree_with_details) }

      describe "#params" do
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
            })
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

          it "course level is UG" do
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
      end
    end
  end
end
