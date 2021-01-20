# frozen_string_literal: true

require "rails_helper"

module Dttp
  module Params
    describe Contact do
      let(:time_now_in_zone) { Time.zone.now }
      let(:trainee) { build(:trainee, gender: "female") }
      let(:trainee_creator_dttp_id) { SecureRandom.uuid }

      subject { described_class.new(trainee, trainee_creator_dttp_id).params }

      before do
        allow(Time).to receive(:now).and_return(time_now_in_zone)
      end

      describe "#params" do
        it "returns a hash with all the DTTP basic contact fields" do
          expect(subject).to include({
            "firstname" => trainee.first_names,
            "lastname" => trainee.last_name,
            "address1_line1" => trainee.address_line_one,
            "address1_line2" => trainee.address_line_two,
            "address1_line3" => trainee.town_city,
            "address1_postalcode" => trainee.postcode,
            "birthdate" => trainee.date_of_birth.to_s,
            "emailaddress1" => trainee.email,
            "gendercode" => Dttp::Params::Contact::GENDER_CODES[:female],
            "dfe_CreatedById@odata.bind" => "/contacts(#{trainee_creator_dttp_id})",
            "parentcustomerid_account@odata.bind" => "/accounts(#{trainee.provider.dttp_id})",
            "dfe_trnassessmentdate" => time_now_in_zone.in_time_zone.iso8601,
          })
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
              expect(subject).to include(disability_param, ethnicity_param)
            end
          end

          context "disclosed" do
            context "ethnicity information" do
              let(:trainee) { build(:trainee, :diversity_disclosed, ethnic_background: ethnic_background) }

              context "provided" do
                let(:ethnic_background) { Diversities::IRISH }

                it "returns a hash with a foreign key of DTTP's 'Irish' ethnicity entity" do
                  expect(subject).to include(ethnicity_param)
                end
              end

              context "not provided" do
                let(:ethnic_background) { Diversities::NOT_PROVIDED }

                it "returns a hash with a foreign of DTTP's 'Not known' ethnicity entity" do
                  expect(subject).to include(ethnicity_param)
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
                    expect(subject).to include(disability_param)
                  end
                end

                context "more than one disability" do
                  let(:dttp_disability) { Diversities::MULTIPLE_DISABILITIES }

                  before do
                    trainee.disabilities += build_list(:disability, 2)
                  end

                  it "returns a hash with a foreign key of DTTP's 'Multiple disabilities' entity" do
                    expect(subject).to include(disability_param)
                  end
                end
              end

              context "not disabled" do
                let(:disability_disclosure) { Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_disabled] }
                let(:dttp_disability) { Diversities::NO_KNOWN_DISABILITY }

                it "returns a hash with a foreign key of DTTP's 'No known disability' entity" do
                  expect(subject).to include(disability_param)
                end
              end

              context "not provided" do
                let(:disability_disclosure) { Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided] }
                let(:dttp_disability) { Diversities::NOT_PROVIDED }

                it "returns a hash with a foreign key of DTTP's 'Not known' entity" do
                  expect(subject).to include(disability_param)
                end
              end
            end
          end
        end
      end
    end
  end
end
