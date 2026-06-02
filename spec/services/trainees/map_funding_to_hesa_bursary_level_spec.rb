# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe MapFundingToHesaBursaryLevel do
    subject { described_class.call(trainee:) }

    let(:trainee) do
      build(
        :trainee,
        training_route:,
        applying_for_bursary:,
        applying_for_grant:,
        applying_for_scholarship:,
        bursary_tier:,
        training_initiative:,
      )
    end

    let(:training_route) { TRAINING_ROUTE_ENUMS[:provider_led_postgrad] }
    let(:applying_for_bursary) { nil }
    let(:applying_for_grant) { nil }
    let(:applying_for_scholarship) { nil }
    let(:bursary_tier) { nil }
    let(:training_initiative) { ROUTE_INITIATIVES_ENUMS[:no_initiative] }

    context "when no funding has been set" do
      it { is_expected.to be_nil }
    end

    # The following codes can't be recovered from the funding fields alone -
    # the inbound mapper collapses undergrad/postgrad/veteran bursaries to a
    # plain applying_for_bursary, so we disambiguate via training_route and
    # training_initiative. These are asserted explicitly rather than round-tripped.
    context "when applying for a bursary on the veteran teaching initiative" do
      let(:applying_for_bursary) { true }
      let(:training_initiative) { ROUTE_INITIATIVES_ENUMS[:veterans_teaching_undergraduate_bursary] }

      it { is_expected.to eq(::Hesa::CodeSets::BursaryLevels::VETERAN_TEACHING_UNDERGRADUATE_BURSARY) }
    end

    context "when applying for a bursary on an undergraduate route" do
      let(:training_route) { TRAINING_ROUTE_ENUMS[:provider_led_undergrad] }
      let(:applying_for_bursary) { true }

      it { is_expected.to eq(::Hesa::CodeSets::BursaryLevels::UNDERGRADUATE_BURSARY) }
    end

    context "when applying for a bursary on a postgraduate route" do
      let(:applying_for_bursary) { true }

      it { is_expected.to eq(::Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY) }
    end

    # HESA bursary level has no single code for grant + tier, so we pick the tier.
    # See PR questions - this is a product/HESA decision, not a code one.
    context "when applying for both a grant and a tiered bursary" do
      let(:applying_for_bursary) { true }
      let(:applying_for_grant) { true }
      let(:bursary_tier) { BURSARY_TIER_ENUMS[:tier_two] }

      it "the tier takes precedence" do
        expect(subject).to eq(::Hesa::CodeSets::BursaryLevels::TIER_TWO)
      end
    end

    # Drift protection: for codes whose Trainee state is fully captured by the
    # funding fields (not route/initiative dependent), feeding them through the
    # inbound mapper and back out again must return the original code. This will
    # fault if MapFundingFromDttpEntityId or the bursary level mappings change.
    describe "round trip with MapFundingFromDttpEntityId" do
      [
        ::Hesa::CodeSets::BursaryLevels::SCHOLARSHIP,
        ::Hesa::CodeSets::BursaryLevels::NONE,
        ::Hesa::CodeSets::BursaryLevels::TIER_ONE,
        ::Hesa::CodeSets::BursaryLevels::TIER_TWO,
        ::Hesa::CodeSets::BursaryLevels::TIER_THREE,
        ::Hesa::CodeSets::BursaryLevels::GRANT,
      ].each do |hesa_code|
        context "for HESA bursary level #{hesa_code}" do
          let(:funding_fields) do
            entity_id = ::Hesa::CodeSets::BursaryLevels::MAPPING[hesa_code]
            MapFundingFromDttpEntityId.call(funding_entity_id: entity_id)
          end

          let(:trainee) do
            build(:trainee, training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad], **funding_fields)
          end

          it "maps the Trainee funding fields back to #{hesa_code}" do
            expect(described_class.call(trainee:)).to eq(hesa_code)
          end
        end
      end
    end
  end
end
