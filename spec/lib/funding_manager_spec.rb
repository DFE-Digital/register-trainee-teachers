# frozen_string_literal: true

require "rails_helper"

describe FundingManager do
  let(:course_subject_one) { nil }
  let(:trainee) { build(:trainee, course_subject_one: course_subject_one) }
  let(:funding_manager) { described_class.new(trainee) }

  describe "#bursary_amount" do
    subject { funding_manager.bursary_amount }

    context "there is no specialism for training route" do
      it "returns nil" do
        expect(subject).to be_nil
      end
    end

    context "there is a specialism for training route" do
      let(:route) { trainee.training_route }
      let(:subject_specialism) { create(:subject_specialism) }
      let(:amount) { 24_000 }
      let(:bursary) { create(:bursary, training_route: route, amount: amount) }

      before do
        create(:bursary_subject, bursary: bursary, allocation_subject: subject_specialism.allocation_subject)
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
      let(:bursary) { create(:bursary, training_route: route) }

      before do
        create(:bursary_subject, bursary: bursary, allocation_subject: subject_specialism.allocation_subject)
      end

      it "returns true" do
        expect(subject).to be_truthy
      end
    end
  end
end
