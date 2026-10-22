# frozen_string_literal: true

require "rails_helper"

module Funding
  describe ReferenceQuery do
    let(:academic_cycle) { create(:academic_cycle, :current) }
    let(:chemistry) { create(:allocation_subject, name: "Chemistry") }
    let(:french) { create(:allocation_subject, name: "French") }
    let(:maths) { create(:allocation_subject, name: "Mathematics") }

    subject(:query) { described_class.new(academic_cycle) }

    before do
      # provider-led postgrad: two bursary bands by subject
      create(:funding_method, training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad], funding_type: :bursary, amount: 29_000, academic_cycle:).tap { |m| m.allocation_subjects << chemistry }
      create(:funding_method, training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad], funding_type: :bursary, amount: 20_000, academic_cycle:).tap { |m| m.allocation_subjects << french }
      # school direct salaried: a grant
      create(:funding_method, training_route: TRAINING_ROUTE_ENUMS[:school_direct_salaried], funding_type: :grant, amount: 16_000, academic_cycle:).tap { |m| m.allocation_subjects << maths }
    end

    describe "#requirements" do
      it "returns one row per route with amount bands per funding type" do
        rows = query.requirements
        expect(rows.map { |r| r[:training_route] }).to contain_exactly(
          TRAINING_ROUTE_ENUMS[:provider_led_postgrad], TRAINING_ROUTE_ENUMS[:school_direct_salaried]
        )

        plp = rows.find { |r| r[:training_route] == TRAINING_ROUTE_ENUMS[:provider_led_postgrad] }
        expect(plp[:amounts]["bursary"]).to eq([29_000, 20_000])
        expect(plp[:amounts]["scholarship"]).to eq([])
        expect(plp[:amounts]["grant"]).to eq([])

        sds = rows.find { |r| r[:training_route] == TRAINING_ROUTE_ENUMS[:school_direct_salaried] }
        expect(sds[:amounts]["grant"]).to eq([16_000])
      end
    end

    describe "#route_bands" do
      it "returns the funding methods (bands) for a route, ordered" do
        bands = query.route_bands(TRAINING_ROUTE_ENUMS[:provider_led_postgrad])
        expect(bands.map(&:amount)).to eq([29_000, 20_000])
      end
    end

    describe "#route_funded?" do
      it "is true for a funded route and false otherwise" do
        expect(query.route_funded?(TRAINING_ROUTE_ENUMS[:provider_led_postgrad])).to be(true)
        expect(query.route_funded?(TRAINING_ROUTE_ENUMS[:iqts])).to be(false)
      end
    end

    describe "#subject_records" do
      it "returns one row per subject allocation, sorted" do
        rows = query.subject_records
        expect(rows.map { |r| r[:subject] }).to eq(%w[Chemistry French Mathematics])
        expect(rows.first).to include(subject: "Chemistry", amount: 29_000, funding_type: "bursary")
      end
    end

    describe "#subject_records change indicator" do
      let(:previous_cycle) { create(:academic_cycle, :previous) }

      before do
        # Chemistry bursary was £25,000 last year (now £29,000 -> increase).
        create(:funding_method, training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad], funding_type: :bursary, amount: 25_000, academic_cycle: previous_cycle).tap { |m| m.allocation_subjects << chemistry }
      end

      it "flags increase, decrease and new against the previous cycle" do
        rows = query.subject_records

        chem = rows.find { |r| r[:subject] == "Chemistry" && r[:training_route] == TRAINING_ROUTE_ENUMS[:provider_led_postgrad] }
        expect(chem[:change]).to eq(:increase)
        expect(chem[:previous_amount]).to eq(25_000)

        french = rows.find { |r| r[:subject] == "French" }
        expect(french[:change]).to eq(:new)
      end
    end
  end
end
