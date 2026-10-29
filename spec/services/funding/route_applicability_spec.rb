# frozen_string_literal: true

require "rails_helper"

module Funding
  describe RouteApplicability do
    let(:plp) { TRAINING_ROUTE_ENUMS[:provider_led_postgrad] }
    let(:plu) { TRAINING_ROUTE_ENUMS[:provider_led_undergrad] }
    let(:pgta) { TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship] }
    let(:eys) { TRAINING_ROUTE_ENUMS[:early_years_salaried] }
    let(:ao) { TRAINING_ROUTE_ENUMS[:assessment_only] }

    describe "grant + Grant method + QTS = yes" do
      subject { described_class.new(funding_type: "grant", funding_method: "E", qts_requirement: "yes") }

      it "keeps the grant QTS routes" do
        expect(subject.applicable?(pgta)).to be(true)
      end

      it "greys an EYTS route with a QTS reason" do
        expect(subject.applicable?(eys)).to be(false)
        expect(subject.reason(eys)).to eq("Leads to EYTS, not QTS")
      end

      it "greys a bursary/scholarship route with a funding-type reason" do
        expect(subject.reason(plp)).to eq("Not available for grant funding")
      end

      it "greys a route that has no funding at all" do
        expect(subject.reason(ao)).to eq("No funding for this route")
      end
    end

    describe "bursary + Undergraduate bursary method" do
      subject { described_class.new(funding_type: "bursary", funding_method: "B", qts_requirement: "yes") }

      it "keeps undergraduate routes and greys postgraduate ones by method" do
        expect(subject.applicable?(plu)).to be(true)
        expect(subject.reason(plp)).to eq("Only for undergraduate routes")
      end
    end

    describe "scholarship" do
      subject { described_class.new(funding_type: "scholarship", funding_method: "4", qts_requirement: "yes") }

      it "keeps provider-led postgraduate and greys undergraduate" do
        expect(subject.applicable?(plp)).to be(true)
        expect(subject.reason(plu)).to eq("Not available for scholarship funding")
      end
    end

    describe "Early years teacher degree apprenticeship" do
      let(:eytda) { TRAINING_ROUTE_ENUMS[:early_years_teacher_degree_apprenticeship] }

      it "is offered for grant funding" do
        service = described_class.new(funding_type: "grant", funding_method: "E")
        expect(service.applicable?(eytda)).to be(true)
      end

      it "is not offered for bursaries" do
        expect(described_class.new(funding_type: "bursary").applicable?(eytda)).to be(false)
      end
    end

    describe "bursary + Early years tiered bursary" do
      subject { described_class.new(funding_type: "bursary", funding_method: "early_years_tiered") }

      it "keeps only the Early years postgraduate route" do
        applicable = TRAINING_ROUTE_ENUMS.values.select { |route| subject.applicable?(route) }
        expect(applicable).to eq([TRAINING_ROUTE_ENUMS[:early_years_postgrad]])
      end
    end

    it "reports when no route is applicable (contradictory answers)" do
      service = described_class.new(funding_type: "scholarship", funding_method: "7", qts_requirement: "yes")
      expect(service.any_applicable?).to be(false)
    end

    it "filters a submitted route list down to the applicable ones" do
      service = described_class.new(funding_type: "grant", funding_method: "E", qts_requirement: "yes")
      expect(service.filter([pgta, eys, plp])).to eq([pgta])
    end
  end
end
