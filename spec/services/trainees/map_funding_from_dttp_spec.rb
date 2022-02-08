# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe MapFundingFromDttp do
    include SeedHelper

    let(:api_placement_assignment) { create(:api_placement_assignment, _dfe_traineestatusid_value: nil) }
    let(:placement_assignment) { create(:dttp_placement_assignment, response: api_placement_assignment) }
    let(:dttp_trainee) { create(:dttp_trainee, placement_assignments: [placement_assignment]) }

    subject { described_class.call(dttp_trainee: dttp_trainee) }

    context "with funding information available" do
      context "when bursary is NO_BURSARY_AWARDED" do
        let(:api_placement_assignment) { create(:api_placement_assignment, :with_no_bursary_awarded) }

        it "sets bursary to false" do
          expect(subject[:applying_for_bursary]).to eq(false)
        end
      end

      context "when the trainee has a scholarship" do
        let(:api_placement_assignment) { create(:api_placement_assignment, :with_scholarship) }

        it "sets scholarship" do
          expect(subject[:applying_for_scholarship]).to eq(true)
        end
      end

      context "when the trainee has a bursary" do
        let(:api_placement_assignment) { create(:api_placement_assignment, :with_provider_led_bursary) }

        it "sets funding" do
          expect(subject[:applying_for_bursary]).to eq(true)
        end
      end

      context "when the trainee has a grant" do
        let(:api_placement_assignment) { create(:api_placement_assignment, :with_early_years_salaried_bursary) }

        it "sets funding" do
          expect(subject[:applying_for_grant]).to eq(true)
        end
      end
    end

    context "with tiered bursary funding" do
      let(:api_placement_assignment) { create(:api_placement_assignment, :with_tiered_bursary) }

      it "sets bursary tier" do
        expect(subject[:applying_for_bursary]).to eq(true)
        expect(subject[:bursary_tier]).to eq(BURSARY_TIER_ENUMS[:tier_two])
      end
    end
  end
end
