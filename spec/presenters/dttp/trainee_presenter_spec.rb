# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe TraineePresenter do
    let(:time_now_in_zone) { Time.zone.now }
    let(:trainee_creator_dttp_id) { SecureRandom.uuid }

    subject { described_class.new(trainee: trainee) }

    describe "#placement_assignment_params" do
      let(:trainee) { create(:trainee, :with_programme_details, dttp_id: dttp_contact_id) }
      let(:dttp_contact_id) { SecureRandom.uuid }
      let(:dttp_age_range_entity_id) { SecureRandom.uuid }
      let(:dttp_programme_subject_entity_id) { SecureRandom.uuid }
      let(:dttp_degree_subject_entity_id) { SecureRandom.uuid }
      let(:dttp_degree_institution_entity_id) { SecureRandom.uuid }
      let(:dttp_degree_grade_entity_id) { SecureRandom.uuid }
      let(:dttp_country_entity_id) { SecureRandom.uuid }
      let(:contact_change_set_id) { SecureRandom.uuid }

      before do
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

      context "UK degree" do
        let(:degree) { create(:degree, :uk_degree_with_details) }

        it "returns a hash with all the UK specific placement assignment fields " do
          expect(subject.placement_assignment_params(contact_change_set_id)).to eq({
            "dfe_programmestartdate" => trainee.programme_start_date.in_time_zone.iso8601,
            "dfe_programmeenddate" => trainee.programme_end_date.in_time_zone.iso8601,
            "dfe_ContactId@odata.bind" => "$#{contact_change_set_id}",
            "dfe_CoursePhaseId@odata.bind" => "/dfe_coursephases(#{dttp_age_range_entity_id})",
            "dfe_ITTSubject1Id@odata.bind" => "/dfe_subjects(#{dttp_programme_subject_entity_id})",
            "dfe_SubjectofUGDegreeId@odata.bind" => "/dfe_jacses(#{dttp_degree_subject_entity_id})",
            "dfe_AwardingInstitutionId@odata.bind" => "/accounts(#{dttp_degree_institution_entity_id})",
            "dfe_ClassofUGDegreeId@odata.bind" => "/dfe_classofdegrees(#{dttp_degree_grade_entity_id})",
            "dfe_sendforsiregistration" => true,
            "dfe_sendforregistrationdate" => time_now_in_zone.iso8601,
          })
        end
      end

      context "Non-UK degree" do
        let(:degree) { create(:degree, :non_uk_degree_with_details) }

        it "returns a hash with all the Non-UK specific placement assignment fields" do
          expect(subject.placement_assignment_params(contact_change_set_id)).to eq({
            "dfe_programmestartdate" => trainee.programme_start_date.in_time_zone.iso8601,
            "dfe_programmeenddate" => trainee.programme_end_date.in_time_zone.iso8601,
            "dfe_ContactId@odata.bind" => "$#{contact_change_set_id}",
            "dfe_CoursePhaseId@odata.bind" => "/dfe_coursephases(#{dttp_age_range_entity_id})",
            "dfe_ITTSubject1Id@odata.bind" => "/dfe_subjects(#{dttp_programme_subject_entity_id})",
            "dfe_SubjectofUGDegreeId@odata.bind" => "/dfe_jacses(#{dttp_degree_subject_entity_id})",
            "dfe_CountryofStudyId@odata.bind" => "/dfe_countries(#{dttp_country_entity_id})",
            "dfe_sendforsiregistration" => true,
            "dfe_sendforregistrationdate" => time_now_in_zone.iso8601,
          })
        end
      end
    end

    describe "#contact_params" do
      let(:trainee) { build(:trainee, gender: "female") }

      before do
        allow(Time).to receive(:now).and_return(time_now_in_zone)
      end

      context "basic information" do
        it "returns a hash with all the DTTP basic contact fields" do
          expect(subject.contact_params(trainee_creator_dttp_id)).to include({
            "firstname" => trainee.first_names,
            "lastname" => trainee.last_name,
            "address1_line1" => trainee.address_line_one,
            "address1_line2" => trainee.address_line_two,
            "address1_line3" => trainee.town_city,
            "address1_postalcode" => trainee.postcode,
            "birthdate" => trainee.date_of_birth.to_s,
            "emailaddress1" => trainee.email,
            "gendercode" => 1,
            "dfe_CreatedById@odata.bind" => "/contacts(#{trainee_creator_dttp_id})",
            "parentcustomerid_account@odata.bind" => "/accounts(#{trainee.provider.dttp_id})",
            "dfe_trnassessmentdate" => time_now_in_zone.in_time_zone.iso8601,
          })
        end
      end

      context "diversity information" do
        let(:dttp_ethnicity_entity_id) { Dttp::CodeSets::Ethnicities::MAPPING[ethnic_background][:entity_id] }
        let(:dttp_disability_entity_id) { Dttp::CodeSets::Disabilities::MAPPING[dttp_disability][:entity_id] }

        let(:disability_param) do
          { "dfe_DisibilityId@odata.bind" => "/dfe_disabilities(#{dttp_disability_entity_id})" }
        end

        let(:ethnicity_param) do
          { "dfe_EthnicityId@odata.bind" => "/dfe_ethnicities(#{dttp_ethnicity_entity_id})" }
        end

        context "undisclosed" do
          let(:trainee) { build(:trainee, :diversity_not_disclosed) }
          let(:ethnic_background) { Diversities::NOT_PROVIDED }
          let(:dttp_disability) { Diversities::NOT_PROVIDED }

          it "returns a hash with a foreign key matching DTTP's 'Not known' ethnicity entity" do
            expect(subject.contact_params(trainee_creator_dttp_id)).to include(disability_param, ethnicity_param)
          end
        end

        context "disclosed" do
          context "ethnicity information" do
            let(:trainee) { build(:trainee, :diversity_disclosed, ethnic_background: ethnic_background) }

            context "provided" do
              let(:ethnic_background) { Diversities::IRISH }

              it "returns a hash with a foreign key of DTTP's 'Irish' ethnicity entity" do
                expect(subject.contact_params(trainee_creator_dttp_id)).to include(ethnicity_param)
              end
            end

            context "not provided" do
              let(:ethnic_background) { Diversities::NOT_PROVIDED }

              it "returns a hash with a foreign of DTTP's 'Not known' ethnicity entity" do
                expect(subject.contact_params(trainee_creator_dttp_id)).to include(ethnicity_param)
              end
            end
          end

          context "disability information" do
            let(:trainee) { create(:trainee, :diversity_disclosed, disability_disclosure: disability_disclosure) }

            context "disabled" do
              let(:disability_disclosure) { Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled] }

              context "only one disability" do
                let(:dttp_disability) { Diversities::BLIND }

                before do
                  trainee.disabilities << create(:disability, name: dttp_disability)
                end

                it "returns a hash with a foreign key of DTTP's 'Blind' disability entity" do
                  expect(subject.contact_params(trainee_creator_dttp_id)).to include(disability_param)
                end
              end

              context "more than one disability" do
                let(:dttp_disability) { Diversities::MULTIPLE_DISABILITIES }

                before do
                  trainee.disabilities += build_list(:disability, 2)
                end

                it "returns a hash with a foreign key of DTTP's 'Multiple disabilities' entity" do
                  expect(subject.contact_params(trainee_creator_dttp_id)).to include(disability_param)
                end
              end
            end

            context "not disabled" do
              let(:disability_disclosure) { Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_disabled] }
              let(:dttp_disability) { Diversities::NO_KNOWN_DISABILITY }

              it "returns a hash with a foreign key of DTTP's 'No known disability' entity" do
                expect(subject.contact_params(trainee_creator_dttp_id)).to include(disability_param)
              end
            end

            context "not provided" do
              let(:disability_disclosure) { Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided] }
              let(:dttp_disability) { Diversities::NOT_PROVIDED }

              it "returns a hash with a foreign key of DTTP's 'Not known' entity" do
                expect(subject.contact_params(trainee_creator_dttp_id)).to include(disability_param)
              end
            end
          end
        end
      end
    end
  end
end
