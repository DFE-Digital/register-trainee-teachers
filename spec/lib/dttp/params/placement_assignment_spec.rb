# frozen_string_literal: true

require "rails_helper"

module Dttp
  module Params
    describe PlacementAssignment do
      let(:time_now_in_zone) { Time.zone.now }
      let(:provider) { create(:provider, dttp_id: dttp_provider_id) }
      let(:trainee) { create(:trainee, :with_programme_details, dttp_id: dttp_contact_id, provider: provider) }

      let(:contact_change_set_id) { SecureRandom.uuid }
      let(:dttp_contact_id) { SecureRandom.uuid }
      let(:dttp_age_range_entity_id) { SecureRandom.uuid }
      let(:dttp_programme_subject_entity_id) { SecureRandom.uuid }
      let(:dttp_degree_subject_entity_id) { SecureRandom.uuid }
      let(:dttp_degree_institution_entity_id) { SecureRandom.uuid }
      let(:dttp_degree_grade_entity_id) { SecureRandom.uuid }
      let(:dttp_country_entity_id) { SecureRandom.uuid }
      let(:dttp_provider_id) { SecureRandom.uuid }

      before do
        allow(Time).to receive(:now).and_return(time_now_in_zone)

        trainee.degrees << degree

        stub_const("Dttp::CodeSets::AgeRanges::MAPPING",
                   { trainee.age_range => { entity_id: dttp_age_range_entity_id } })
        stub_const("Dttp::CodeSets::ProgrammeSubjects::MAPPING",
                   { trainee.subject => { entity_id: dttp_programme_subject_entity_id } })
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
              "dfe_programmestartdate" => trainee.programme_start_date.in_time_zone.iso8601,
              "dfe_programmeenddate" => trainee.programme_end_date.in_time_zone.iso8601,
              "dfe_ContactId@odata.bind" => "$#{contact_change_set_id}",
              "dfe_CoursePhaseId@odata.bind" => "/dfe_coursephases(#{dttp_age_range_entity_id})",
              "dfe_ITTSubject1Id@odata.bind" => "/dfe_subjects(#{dttp_programme_subject_entity_id})",
              "dfe_SubjectofUGDegreeId@odata.bind" => "/dfe_jacses(#{dttp_degree_subject_entity_id})",
              "dfe_AwardingInstitutionId@odata.bind" => "/accounts(#{dttp_degree_institution_entity_id})",
              "dfe_ClassofUGDegreeId@odata.bind" => "/dfe_classofdegrees(#{dttp_degree_grade_entity_id})",
              "dfe_traineeid" => trainee.trainee_id,
              "dfe_AcademicYearId@odata.bind" => "/dfe_academicyears(#{Dttp::Params::PlacementAssignment::ACADEMIC_YEAR_2020_2021})",
              "dfe_courselevel" => Dttp::Params::PlacementAssignment::COURSE_LEVEL_PG,
              "dfe_sendforregistration" => true,
              "dfe_ProviderId@odata.bind" => "/accounts(#{dttp_provider_id})",
              "dfe_ITTQualificationAimId@odata.bind" => "/dfe_ittqualificationaims(#{Dttp::Params::PlacementAssignment::ITT_QUALIFICATION_AIM_QTS})",
              "dfe_programmeyear" => 1,
              "dfe_programmelength" => 1,
              "dfe_RouteId@odata.bind" => "/dfe_routes(#{Dttp::Params::PlacementAssignment::ASSESSMENT_ONLY_DTTP_ID})",
            })
          end
        end

        context "Non-UK degree" do
          let(:degree) { build(:degree, :non_uk_degree_with_details) }

          it "returns a hash with all the Non-UK specific placement assignment fields" do
            expect(subject).to eq({
              "dfe_programmestartdate" => trainee.programme_start_date.in_time_zone.iso8601,
              "dfe_programmeenddate" => trainee.programme_end_date.in_time_zone.iso8601,
              "dfe_ContactId@odata.bind" => "$#{contact_change_set_id}",
              "dfe_CoursePhaseId@odata.bind" => "/dfe_coursephases(#{dttp_age_range_entity_id})",
              "dfe_ITTSubject1Id@odata.bind" => "/dfe_subjects(#{dttp_programme_subject_entity_id})",
              "dfe_SubjectofUGDegreeId@odata.bind" => "/dfe_jacses(#{dttp_degree_subject_entity_id})",
              "dfe_CountryofStudyId@odata.bind" => "/dfe_countries(#{dttp_country_entity_id})",
              "dfe_traineeid" => trainee.trainee_id,
              "dfe_AcademicYearId@odata.bind" => "/dfe_academicyears(#{Dttp::Params::PlacementAssignment::ACADEMIC_YEAR_2020_2021})",
              "dfe_courselevel" => Dttp::Params::PlacementAssignment::COURSE_LEVEL_PG,
              "dfe_sendforregistration" => true,
              "dfe_ProviderId@odata.bind" => "/accounts(#{dttp_provider_id})",
              "dfe_ITTQualificationAimId@odata.bind" => "/dfe_ittqualificationaims(#{Dttp::Params::PlacementAssignment::ITT_QUALIFICATION_AIM_QTS})",
              "dfe_programmeyear" => 1,
              "dfe_programmelength" => 1,
              "dfe_RouteId@odata.bind" => "/dfe_routes(#{Dttp::Params::PlacementAssignment::ASSESSMENT_ONLY_DTTP_ID})",
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
          let(:trainee) { create(:trainee, :with_programme_details, dttp_id: dttp_contact_id, provider: provider, trainee_id: nil) }

          it "passes NOTPROVIDED for dfe_traineeid" do
            expect(subject).to include(
              { "dfe_traineeid" => "NOTPROVIDED" },
            )
          end
        end
      end
    end
  end
end
