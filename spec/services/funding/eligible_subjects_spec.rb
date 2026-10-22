# frozen_string_literal: true

require "rails_helper"

module Funding
  describe EligibleSubjects do
    let!(:early_years_itt) { create(:allocation_subject, name: AllocationSubjects::EARLY_YEARS_ITT) }
    let!(:chemistry) { create(:allocation_subject, name: "Chemistry") }

    let(:early_years_routes) { [TRAINING_ROUTE_ENUMS[:early_years_postgrad]] }
    let(:other_routes) { [TRAINING_ROUTE_ENUMS[:provider_led_postgrad]] }

    describe ".early_years?" do
      it "is true for every early years route, including assessment only" do
        EARLY_YEARS_TRAINING_ROUTES.each_key do |route|
          expect(described_class.early_years?([route])).to be(true)
        end
      end

      it "is false for other routes" do
        expect(described_class.early_years?(other_routes)).to be(false)
        expect(described_class.early_years?([])).to be(false)
      end
    end

    describe ".automatic?" do
      it "is true for early years routes when the Early years ITT subject exists" do
        expect(described_class.automatic?(early_years_routes)).to be(true)
      end

      it "is false when there is no Early years ITT subject to set" do
        early_years_itt.update!(deprecated_on: Time.zone.today)
        expect(described_class.automatic?(early_years_routes)).to be(false)
      end
    end

    describe ".for" do
      it "offers only Early years ITT for early years routes" do
        expect(described_class.for(early_years_routes)).to contain_exactly(early_years_itt)
      end

      it "offers every other subject for other routes" do
        expect(described_class.for(other_routes)).to include(chemistry)
        expect(described_class.for(other_routes)).not_to include(early_years_itt)
      end
    end

    describe ".error_for" do
      it "accepts Early years ITT for early years routes" do
        expect(described_class.error_for(early_years_routes, [early_years_itt.id])).to be_nil
      end

      it "rejects other subjects for early years routes" do
        expect(described_class.error_for(early_years_routes, [chemistry.id])).to eq("Select Early years ITT for early years training routes")
      end

      it "rejects Early years ITT for other routes" do
        expect(described_class.error_for(other_routes, [early_years_itt.id])).to eq("Early years ITT is only for early years training routes")
      end
    end
  end
end
