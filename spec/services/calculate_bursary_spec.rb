# frozen_string_literal: true

require "rails_helper"

describe CalculateBursary do
  describe "#available_for_route?" do
    let(:route) { TRAINING_ROUTE_ENUMS[:provider_led_postgrad] }

    context "when there is a bursary available for a given route" do
      before { create(:funding_method, :with_bursary_subjects, training_route: route) }

      it "returns true" do
        expect(described_class.available_for_route?(route.to_sym)).to be_truthy
      end
    end

    context "when there is a bursary available for a given route but it has no subjects" do
      before { create(:funding_method, training_route: route) }

      it "returns true" do
        expect(described_class.available_for_route?(route.to_sym)).to be_falsey
      end
    end

    context "when there is no bursary available for a given route" do
      it "returns false" do
        expect(described_class.available_for_route?(route.to_sym)).to be_falsey
      end
    end

    context "when the route is not recognised" do
      it "raises an error" do
        expect {
          described_class.available_for_route?("not_a_route")
        }.to raise_error("Training route 'not_a_route' not recognised")
      end
    end
  end

  describe "#for_tier" do
    it { expect(described_class.for_tier("invalid")).to be_nil }
    it { expect(described_class.for_tier(BURSARY_TIERS.keys.first)).to eq 5000 }
    it { expect(described_class.for_tier(BURSARY_TIERS.keys.second)).to eq 4000 }
    it { expect(described_class.for_tier(BURSARY_TIERS.keys.third)).to eq 2000 }
  end

  describe "#for_route_and_subject" do
    let(:route) { TRAINING_ROUTE_ENUMS[:provider_led_postgrad] }
    let(:subject_specialism) { create(:subject_specialism) }
    let(:amount) { 24_000 }

    context "when there is a bursary available for a given route and subject" do
      let(:funding_method) { create(:funding_method, training_route: route, amount: amount) }

      before do
        create(:funding_method_subject, funding_method: funding_method, allocation_subject: subject_specialism.allocation_subject)
      end

      it "returns bursary amount" do
        expect(described_class.for_route_and_subject(route.to_sym, subject_specialism.name)).to eq amount
      end
    end

    context "when there is a bursary for the route but not the subject" do
      let(:funding_method) { create(:funding_method, training_route: route) }

      it "returns nil" do
        expect(described_class.for_route_and_subject(route.to_sym, subject_specialism.name)).to be_nil
      end
    end

    context "when there is a bursary for subject but not the route" do
      let(:funding_method) { create(:funding_method, training_route: TRAINING_ROUTE_ENUMS[:assessment_only]) }

      before do
        create(:funding_method_subject, funding_method: funding_method, allocation_subject: subject_specialism.allocation_subject)
      end

      it "returns nil" do
        expect(described_class.for_route_and_subject(route.to_sym, subject_specialism.name)).to be_nil
      end
    end

    context "when there is no bursary for the route nor the subject" do
      it "returns nil" do
        expect(described_class.for_route_and_subject(route.to_sym, subject_specialism.name)).to be_nil
      end
    end

    context "when the route is not recognised" do
      it "raises an error" do
        expect {
          described_class.for_route_and_subject("not_a_route", subject_specialism.name)
        }.to raise_error("Training route 'not_a_route' not recognised")
      end
    end
  end
end
