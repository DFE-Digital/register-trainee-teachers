# frozen_string_literal: true

require "rails_helper"

module Funding
  describe ReferenceReport do
    let(:academic_cycle) { create(:academic_cycle, :current) }
    let(:chemistry) { create(:allocation_subject, name: "Chemistry") }

    subject(:report) { described_class.new(academic_cycle) }

    before do
      create(:funding_method, training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad], funding_type: :bursary, amount: 29_000, academic_cycle: academic_cycle).tap { |m| m.allocation_subjects << chemistry }
    end

    describe "#to_csv" do
      it "produces a header row and one row per band with subjects" do
        csv = CSV.parse(report.to_csv)
        expect(csv.first).to eq(%w[academic_year training_route funding_type training_year amount availability subjects])
        expect(csv.second).to eq([academic_cycle.label, "provider_led_postgrad", "bursary", nil, "29000", "available", "Chemistry"])
      end
    end

    describe "#to_h" do
      it "returns title, columns and rows" do
        result = report.to_h
        expect(result[:columns]).to include("amount", "subjects")
        expect(result[:rows].first).to include(training_route: "provider_led_postgrad", amount: 29_000, subjects: "Chemistry")
      end
    end

    describe "#rows_by_funding_type" do
      before do
        create(:funding_method, training_route: TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship], funding_type: :grant, amount: 15_000, academic_cycle: academic_cycle)
      end

      it "groups rows by funding type in bursary, scholarship, grant order" do
        grouped = report.rows_by_funding_type
        expect(grouped.keys).to eq(%w[bursary grant])
        expect(grouped["bursary"].map { |row| row[:amount] }).to eq([29_000])
      end
    end

    describe "#filename" do
      it "is scoped to the cycle and format" do
        expect(report.filename(:csv)).to match(/funding-requirements-.*\.csv/)
      end
    end
  end
end
