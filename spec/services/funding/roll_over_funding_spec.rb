# frozen_string_literal: true

require "rails_helper"

module Funding
  describe RollOverFunding do
    let(:source) { AcademicCycle.current || create(:academic_cycle, :current) }
    let(:target) { AcademicCycle.next || create(:academic_cycle, next_cycle: true) }
    let(:chemistry) { create(:allocation_subject, name: "Chemistry") }
    let(:deprecated_subject) { create(:allocation_subject, name: "Old subject", deprecated_on: 1.year.ago) }

    it "copies funding methods (and non-deprecated subjects) into the target cycle" do
      method = create(:funding_method,
                      training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad], funding_type: :bursary,
                      amount: 29_000, degree_relevance: :relevant, funding_method: "D", academic_cycle: source)
      method.allocation_subjects << chemistry
      method.allocation_subjects << deprecated_subject

      expect { described_class.call(source:, target:) }.to change { target.funding_methods.count }.by(1)

      copied = target.funding_methods.first
      expect(copied).to have_attributes(
        training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
        funding_type: "bursary", amount: 29_000, degree_relevance: "relevant", funding_method: "D"
      )
      expect(copied.allocation_subjects.pluck(:name)).to contain_exactly("Chemistry") # deprecated skipped
      expect(copied.reference_number).to be_present
    end

    it "doesn't copy EYTDA amounts, which carry forward by themselves" do
      create(:funding_method, training_route: FundingManager::EYTDA_ROUTE, funding_type: :grant, amount: 8_236,
                              training_year: 1, academic_cycle: source)

      expect { described_class.call(source:, target:) }.not_to(change { target.funding_methods.count })
    end

    it "returns the number of records created" do
      create(:funding_method, academic_cycle: source)
      create(:funding_method, academic_cycle: source)
      expect(described_class.call(source:, target:)).to eq(2)
    end

    it "does not touch the source cycle" do
      create(:funding_method, academic_cycle: source)
      expect { described_class.call(source:, target:) }.not_to change { source.funding_methods.count }
    end
  end
end
