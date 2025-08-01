# frozen_string_literal: true

require "rails_helper"

module TeacherTrainingApi
  RSpec.describe PublishProviderChecker, type: :service do
    let(:recruitment_cycle_year) { Settings.current_recruitment_cycle_year }

    describe "#call" do
      before do
        allow(Client::Request).to receive(:get).and_return(double(parsed_response: response))
      end

      subject { described_class.call(recruitment_cycle_year:) }

      context "with valid response" do
        let(:response) do
          {
            "data" => [
              { "attributes" => provider1_attributes },
              { "attributes" => provider2_attributes },
              { "attributes" => school_attributes },
              { "attributes" => lead_partner_attributes },
              { "attributes" => missing_attributes },
            ],
            "links" => { "next" => nil },
          }
        end

        let(:provider1_attributes) { { "code" => provider1.code, "ukprn" => nil, "urn" => nil } }
        let(:provider2_attributes) { { "code" => nil, "ukprn" => provider2.ukprn, "urn" => nil } }
        let(:school_attributes) { { "code" => nil, "ukprn" => nil, "urn" => school.urn, "accredited_body" => false } }
        let(:lead_partner_attributes) { { "code" => nil, "ukprn" => nil, "urn" => lead_partner.urn } }
        let(:missing_attributes) { { "code" => "M0M", "ukprn" => "12344321", "urn" => "54321", "accredited_body" => true } }

        let(:provider1) { create(:provider) }
        let(:provider2) { create(:provider) }
        let(:school) { create(:school) }
        let(:lead_partner) { create(:lead_partner, :hei) }

        it "returns the correct value for provider_matches" do
          expect(subject.provider_matches).to contain_exactly(provider1_attributes, provider2_attributes)
        end

        it "returns the correct value for lead_partner_matches" do
          expect(subject.lead_partner_matches).to contain_exactly(lead_partner_attributes)
        end

        it "returns the correct value for missing" do
          expect(subject.missing).to contain_exactly(
            school_attributes,
            missing_attributes,
          )
        end

        it "returns the correct value for missing_accredited" do
          expect(subject.missing_accredited).to contain_exactly(missing_attributes)
        end

        it "returns the correct value for missing_unaccredited" do
          expect(subject.missing_unaccredited).to contain_exactly(school_attributes)
        end

        it "returns the correct value for total_count" do
          expect(subject.total_count).to be(5)
        end
      end
    end
  end
end
