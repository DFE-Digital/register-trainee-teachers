# frozen_string_literal: true

require "rails_helper"

describe FundingManager do
  let(:course_subject_one) { nil }
  let(:bursary_tier) { nil }
  let(:training_route) { :early_years_postgrad }
  let(:trainee) { build(:trainee, course_subject_one: course_subject_one, training_route: training_route, bursary_tier: bursary_tier) }
  let(:funding_manager) { described_class.new(trainee) }

  describe "#bursary_amount" do
    subject { funding_manager.bursary_amount }

    {
      tier_one: 5000,
      tier_two: 4000,
      tier_three: 2000,
    }.each do |tier, amount|
      context "the trainee bursary tier is set to #{tier.to_s.humanize}" do
        let(:bursary_tier) { tier }

        it "returns amount" do
          expect(subject).to be amount
        end
      end
    end

    context "there is no trainee bursary tier" do
      context "there is no specialism for training route" do
        it "returns nil" do
          expect(subject).to be_nil
        end
      end

      context "there is a specialism for training route" do
        let(:subject_specialism) { create(:subject_specialism) }
        let(:amount) { 24_000 }
        let(:funding_method) { create(:funding_method, training_route: training_route, amount: amount) }

        before do
          create(:funding_method_subject, funding_method: funding_method, allocation_subject: subject_specialism.allocation_subject)
        end

        context "without trainee course subject one" do
          it "returns nil" do
            expect(subject).to be_nil
          end
        end

        context "with trainee course subject one" do
          let(:course_subject_one) { subject_specialism.name }

          it "returns amount" do
            expect(subject).to be amount
          end
        end
      end
    end
  end

  describe "#scholarship_amount" do
    subject { funding_manager.scholarship_amount }

    context "there is no specialism for training route" do
      it "returns nil" do
        expect(subject).to be_nil
      end
    end

    context "there is a specialism for training route" do
      let(:subject_specialism) { create(:subject_specialism) }
      let(:amount) { 9_000 }
      let(:funding_method) { create(:funding_method, :scholarship, training_route: training_route, amount: amount) }

      before do
        create(:funding_method_subject, funding_method: funding_method, allocation_subject: subject_specialism.allocation_subject)
      end

      context "without trainee course subject one" do
        it "returns nil" do
          expect(subject).to be_nil
        end
      end

      context "with trainee course subject one" do
        let(:course_subject_one) { subject_specialism.name }

        it "returns amount" do
          expect(subject).to be amount
        end
      end
    end
  end

  describe "#funding_available?" do
    subject { funding_manager.funding_available? }

    context "there is no specialism for training route" do
      it "returns false" do
        expect(subject).to be_falsey
      end
    end

    context "there is a specialism for training route" do
      let(:route) { trainee.training_route }
      let(:subject_specialism) { create(:subject_specialism) }
      let(:funding_method) { create(:funding_method, training_route: route) }

      before do
        create(:funding_method_subject, funding_method: funding_method, allocation_subject: subject_specialism.allocation_subject)
      end

      it "returns true" do
        expect(subject).to be_truthy
      end
    end
  end

  describe "#can_apply_for_bursary?" do
    subject { funding_manager.can_apply_for_bursary? }

    context "training route early years postgrad" do
      let(:training_route) { :early_years_postgrad }

      it "returns true" do
        expect(subject).to be_truthy
      end
    end

    TRAINING_ROUTE_ENUMS.keys.reject { |x| x == :early_years_postgrad }.map do |route|
      let(:training_route) { route }

      context "training route #{route.to_s.humanize}" do
        it "returns false" do
          expect(subject).to be_falsey
        end

        context "with trainee course subject one" do
          let(:course_subject_one) { subject_specialism.name }

          let(:subject_specialism) { create(:subject_specialism) }
          let(:amount) { 24_000 }
          let(:funding_method) { create(:funding_method, training_route: training_route, amount: amount) }

          before do
            create(:funding_method_subject, funding_method: funding_method, allocation_subject: subject_specialism.allocation_subject)
          end

          it "returns true" do
            expect(subject).to be_truthy
          end
        end
      end
    end
  end
end
