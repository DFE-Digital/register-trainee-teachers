# frozen_string_literal: true

require "rails_helper"

describe FundingManager do
  let(:course_subject_one) { nil }
  let(:bursary_tier) { nil }
  let(:training_route) { :early_years_postgrad }
  let(:funding_manager) { described_class.new(trainee) }
  let(:trainee) do
    create(:trainee,
           :with_study_mode_and_course_dates,
           :with_course_allocation_subject,
           course_subject_one:,
           training_route:,
           bursary_tier:)
  end

  before do
    create(:academic_cycle, :current)
  end

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
        let(:funding_method) { create(:funding_method, training_route:, amount:) }

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
      let(:funding_method) { create(:funding_method, :scholarship, training_route:, amount:) }

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

  describe "#grant_amount" do
    subject { funding_manager.grant_amount }

    context "there is no specialism for training route" do
      it "returns nil" do
        expect(subject).to be_nil
      end
    end

    context "there is a specialism for training route" do
      let(:subject_specialism) { create(:subject_specialism) }
      let(:amount) { 9_000 }
      let(:funding_method) { create(:funding_method, :grant, training_route:, amount:) }

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
          expect(subject).to be(amount)
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

      context "funding type grant" do
        let(:funding_method) do
          create(:funding_method, :grant, training_route: route)
        end

        it "returns true" do
          expect(subject).to be_truthy
        end
      end
    end

    context "when academic year is nil for trainee" do
      let(:trainee_without_start_dates) { create(:trainee, training_route: :assessment_only) }
      let(:subject_specialism) { create(:subject_specialism) }
      let(:previous_academic_cycle) { create(:academic_cycle, previous_cycle: true) }
      let(:funding_manager) { described_class.new(trainee_without_start_dates) }

      before do
        allow(Trainees::SetAcademicCycles).to receive(:call) # deactivate so it doesn't override factories
        create(:funding_method_subject, funding_method: funding_method, allocation_subject: subject_specialism.allocation_subject)
      end

      context "and the route is funded in another academic year" do
        let(:funding_method) { create(:funding_method, training_route: trainee_without_start_dates.training_route, academic_cycle: previous_academic_cycle) }

        it "returns true" do
          expect(subject).to be_truthy
        end
      end

      ReferenceData::TRAINING_ROUTES.names_with_hesa_codes.reject { |x| x == :assessment_only }.map do |route|
        context "and the #{route} route is not funded in another academic year" do
          let(:funding_method) { create(:funding_method, training_route: route, academic_cycle: previous_academic_cycle) }

          it "returns false" do
            expect(subject).to be_falsey
          end
        end
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

    ReferenceData::TRAINING_ROUTES.names.reject { |x| x == :early_years_postgrad }.map do |route|
      let(:training_route) { route }

      context "training route #{route.to_s.humanize}" do
        it "returns false" do
          expect(subject).to be_falsey
        end

        context "with trainee course subject one" do
          let(:course_subject_one) { subject_specialism.name }
          let(:subject_specialism) { create(:subject_specialism) }
          let(:amount) { 24_000 }
          let(:funding_method) { create(:funding_method, training_route:, amount:) }

          before do
            create(:funding_method_subject,
                   funding_method: funding_method,
                   allocation_subject: subject_specialism.allocation_subject)
          end

          it { is_expected.to be_truthy }
        end
      end
    end
  end

  describe "#can_apply_for_tiered_bursary?" do
    subject { funding_manager.can_apply_for_tiered_bursary? }

    context "training route early years postgrad" do
      let(:training_route) { :early_years_postgrad }

      it "returns true" do
        expect(subject).to be_truthy
      end
    end

    ReferenceData::TRAINING_ROUTES.names_with_hesa_codes.reject { |x| x == :early_years_postgrad }.map do |route|
      let(:training_route) { route }

      context "training route #{route.to_s.humanize}" do
        it "returns false" do
          expect(subject).to be_falsey
        end
      end
    end
  end

  describe "#applicable_available_funding" do
    subject { funding_manager.applicable_available_funding }

    context "training route early years postgrad" do
      let(:training_route) { :early_years_postgrad }

      it "returns grant_and_tiered_bursary" do
        expect(subject).to be(:grant_and_tiered_bursary)
      end
    end

    context "there is a specialism for training route" do
      let(:subject_specialism) { create(:subject_specialism) }
      let(:amount) { 9_000 }
      let(:funding_method) { create(:funding_method, :grant, training_route:, amount:) }
      let(:training_route) do
        ReferenceData::TRAINING_ROUTES.names.reject { |x| x == "early_years_postgrad" }.sample
      end

      before do
        create(:funding_method_subject, funding_method: funding_method, allocation_subject: subject_specialism.allocation_subject)
      end

      context "without trainee course subject one" do
        it "returns non_tiered_bursary" do
          expect(subject).to be(:non_tiered_bursary)
        end
      end

      context "with trainee course subject one" do
        let(:course_subject_one) { subject_specialism.name }

        it "returns grant" do
          expect(subject).to be(:grant)
        end
      end
    end
  end
end
