# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe MapFundingToHesa do
    describe "::call" do
      subject(:result) { described_class.call(trainee:) }

      context "when the trainee is not applying for any funding" do
        let(:trainee) do
          build(:trainee,
                applying_for_bursary: false,
                applying_for_scholarship: false,
                applying_for_grant: false)
        end

        it { is_expected.to eq(::Hesa::CodeSets::BursaryLevels::NONE) }
      end

      context "when the trainee is applying for a scholarship" do
        let(:trainee) { build(:trainee, applying_for_scholarship: true) }

        it { is_expected.to eq(::Hesa::CodeSets::BursaryLevels::SCHOLARSHIP) }
      end

      context "when the trainee is applying for a grant" do
        let(:trainee) { build(:trainee, applying_for_grant: true) }

        it { is_expected.to eq(::Hesa::CodeSets::BursaryLevels::GRANT) }
      end

      context "when the trainee is applying for both a grant and a tiered bursary" do
        let(:trainee) do
          build(:trainee,
                applying_for_grant: true,
                applying_for_bursary: true,
                bursary_tier: :tier_one)
        end

        it "prefers the tier over the grant" do
          expect(result).to eq(::Hesa::CodeSets::BursaryLevels::TIER_ONE)
        end
      end

      context "when the trainee is applying for a tiered bursary" do
        let(:trainee) { build(:trainee, applying_for_bursary: true, bursary_tier: tier) }

        context "tier one" do
          let(:tier) { :tier_one }

          it { is_expected.to eq(::Hesa::CodeSets::BursaryLevels::TIER_ONE) }
        end

        context "tier two" do
          let(:tier) { :tier_two }

          it { is_expected.to eq(::Hesa::CodeSets::BursaryLevels::TIER_TWO) }
        end

        context "tier three" do
          let(:tier) { :tier_three }

          it { is_expected.to eq(::Hesa::CodeSets::BursaryLevels::TIER_THREE) }
        end
      end

      context "when the trainee is applying for a non-tiered bursary on a postgrad route" do
        let(:trainee) do
          build(:trainee,
                training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
                applying_for_bursary: true,
                bursary_tier: nil)
        end

        it { is_expected.to eq(::Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY) }
      end

      context "when the trainee is applying for a non-tiered bursary on an undergrad route" do
        let(:trainee) do
          build(:trainee,
                training_route: TRAINING_ROUTE_ENUMS[:provider_led_undergrad],
                applying_for_bursary: true,
                bursary_tier: nil)
        end

        it { is_expected.to eq(::Hesa::CodeSets::BursaryLevels::UNDERGRADUATE_BURSARY) }
      end

      context "when the training_initiative is veterans teaching undergraduate bursary" do
        let(:trainee) do
          build(:trainee,
                training_route: TRAINING_ROUTE_ENUMS[:provider_led_undergrad],
                training_initiative: ROUTE_INITIATIVES_ENUMS[:veterans_teaching_undergraduate_bursary],
                applying_for_bursary: true,
                bursary_tier: nil)
        end

        it { is_expected.to eq(::Hesa::CodeSets::BursaryLevels::VETERAN_TEACHING_UNDERGRADUATE_BURSARY) }

        context "but the trainee is on a postgrad route" do
          let(:trainee) do
            build(:trainee,
                  training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
                  training_initiative: ROUTE_INITIATIVES_ENUMS[:veterans_teaching_undergraduate_bursary],
                  applying_for_bursary: true,
                  bursary_tier: nil)
          end

          it { is_expected.to eq(::Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY) }
        end

        context "but the trainee is not applying for a bursary" do
          let(:trainee) do
            build(:trainee,
                  training_initiative: ROUTE_INITIATIVES_ENUMS[:veterans_teaching_undergraduate_bursary],
                  applying_for_bursary: false)
          end

          it { is_expected.to eq(::Hesa::CodeSets::BursaryLevels::NONE) }
        end
      end

      context "when the existing HESA funding_method is veteran but training_initiative is not" do
        let(:trainee) do
          create(:trainee,
                 training_route: TRAINING_ROUTE_ENUMS[:provider_led_undergrad],
                 training_initiative: ROUTE_INITIATIVES_ENUMS[:no_initiative],
                 applying_for_bursary: true,
                 bursary_tier: nil)
        end

        before do
          trainee.create_hesa_trainee_detail!(
            funding_method: ::Hesa::CodeSets::BursaryLevels::VETERAN_TEACHING_UNDERGRADUATE_BURSARY,
          )
        end

        it "recomputes from training_initiative rather than preserving the stored value" do
          expect(result).to eq(::Hesa::CodeSets::BursaryLevels::UNDERGRADUATE_BURSARY)
        end
      end
    end
  end
end
