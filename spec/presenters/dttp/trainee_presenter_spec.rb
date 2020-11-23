# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe TraineePresenter do
    subject { described_class.new(trainee: trainee) }

    describe "#placement_assignment_params" do
      let(:trainee) { build(:trainee, :with_programme_details) }
      let(:dttp_age_range_entity_id) { Dttp::CodeSets::AgeRanges::MAPPING[age_range][:entity_id] }
      let(:dttp_subject_entity_id) { Dttp::CodeSets::ProgrammeSubjects::MAPPING[programme_subject][:entity_id] }
      let(:age_range) { trainee.age_range }
      let(:programme_subject) { trainee.subject }

      it "returns a hash with all the placement assignment fields" do
        expect(subject.placement_assignment_params).to include({
          "dfe_programmestartdate" => trainee.programme_start_date.in_time_zone.iso8601,
          "dfe_ContactId@odata.bind" => "/contacts(#{trainee.dttp_id})",
          "dfe_CoursePhaseId@odata.bind" => "/dfe_coursephases(#{dttp_age_range_entity_id})",
          "dfe_ITTSubject1Id@odata.bind" => "/dfe_subjects(#{dttp_subject_entity_id})",
        })
      end
    end

    describe "#contact_params" do
      let(:trainee) { build(:trainee) }

      context "basic information" do
        it "returns a hash with all the DTTP basic contact fields" do
          expect(subject.contact_params).to include({
            "firstname" => trainee.first_names,
            "lastname" => trainee.last_name,
            "contactid" => trainee.dttp_id,
            "address1_line1" => trainee.address_line_one,
            "address1_line2" => trainee.address_line_two,
            "address1_line3" => trainee.town_city,
            "address1_postalcode" => trainee.postcode,
            "birthdate" => trainee.date_of_birth.strftime("%d/%m/%Y"),
            "emailaddress1" => trainee.email,
            "gendercode" => trainee.gender,
            "mobilephone" => trainee.phone_number,
          })
        end
      end

      context "diversity information" do
        let(:dttp_ethnicity_entity_id) { Dttp::CodeSets::Ethnicities::MAPPING[ethnic_background][:entity_id] }
        let(:dttp_disability_entity_id) { Dttp::CodeSets::Disabilities::MAPPING[dttp_disability][:entity_id] }

        context "undisclosed" do
          let(:trainee) { build(:trainee, :diversity_not_disclosed) }
          let(:ethnic_background) { Diversities::NOT_PROVIDED }
          let(:dttp_disability) { Diversities::NOT_PROVIDED }

          it "returns a hash with a foreign key matching DTTP's 'Not known' ethnicity entity" do
            expect(subject.contact_params).to include("_dfe_ethnicityid_value" => dttp_ethnicity_entity_id,
                                                      "_dfe_disibilityid_value" => dttp_disability_entity_id)
          end
        end

        context "disclosed" do
          context "ethnicity information" do
            let(:trainee) { build(:trainee, :diversity_disclosed, ethnic_background: ethnic_background) }

            context "provided" do
              let(:ethnic_background) { Diversities::IRISH }

              it "returns a hash with a foreign key of DTTP's 'Irish' ethnicity entity" do
                expect(subject.contact_params).to include("_dfe_ethnicityid_value" => dttp_ethnicity_entity_id)
              end
            end

            context "not provided" do
              let(:ethnic_background) { Diversities::NOT_PROVIDED }

              it "returns a hash with a foreign of DTTP's 'Not known' ethnicity entity" do
                expect(subject.contact_params).to include("_dfe_ethnicityid_value" => dttp_ethnicity_entity_id)
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
                  expect(subject.contact_params).to include("_dfe_disibilityid_value" => dttp_disability_entity_id)
                end
              end

              context "more than one disability" do
                let(:dttp_disability) { Diversities::MULTIPLE_DISABILITIES }

                before do
                  trainee.disabilities += build_list(:disability, 2)
                end

                it "returns a hash with a foreign key of DTTP's 'Multiple disabilities' entity" do
                  expect(subject.contact_params).to include("_dfe_disibilityid_value" => dttp_disability_entity_id)
                end
              end
            end

            context "not disabled" do
              let(:disability_disclosure) { Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_disabled] }
              let(:dttp_disability) { Diversities::NO_KNOWN_DISABILITY }

              it "returns a hash with a foreign key of DTTP's 'No known disability' entity" do
                expect(subject.contact_params).to include("_dfe_disibilityid_value" => dttp_disability_entity_id)
              end
            end

            context "not provided" do
              let(:disability_disclosure) { Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided] }
              let(:dttp_disability) { Diversities::NOT_PROVIDED }

              it "returns a hash with a foreign key of DTTP's 'Not known' entity" do
                expect(subject.contact_params).to include("_dfe_disibilityid_value" => dttp_disability_entity_id)
              end
            end
          end
        end
      end
    end
  end
end
