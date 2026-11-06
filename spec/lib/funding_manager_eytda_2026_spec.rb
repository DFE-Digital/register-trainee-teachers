# frozen_string_literal: true

require "rails_helper"

# EYTDA funding is managed from 2026 to 2027, a year before other routes, so a
# 2026 to 2027 EYTDA trainee only gets it once it's signed off.
describe FundingManager do
  around { |example| Timecop.travel(Date.new(2026, 10, 12)) { example.run } }

  let(:cycle) { AcademicCycle.for_year(2026) || create(:academic_cycle, start_date: Date.new(2026, 8, 1), end_date: Date.new(2027, 7, 31)) }
  let(:allocation_subject) { create(:allocation_subject) }
  let(:funding_manager) { described_class.new(trainee) }

  before { enable_features(:funding_eligibility_step) }

  context "for an EYTDA trainee starting in 2026 to 2027" do
    let(:trainee) do
      build(:trainee, training_route: FundingManager::EYTDA_ROUTE, course_allocation_subject: allocation_subject, start_academic_cycle: cycle)
    end

    it "manages the funding from 2026" do
      expect(described_class.funding_management_start_year(FundingManager::EYTDA_ROUTE)).to eq(2026)
    end

    it "isn't signed off until the year's EYTDA funding is approved" do
      expect(funding_manager.funding_signed_off?).to be(false)
    end

    it "is signed off once approved" do
      cycle.update!(published: true)

      expect(described_class.new(trainee).funding_signed_off?).to be(true)
    end
  end

  context "for another route starting in 2026 to 2027" do
    let(:trainee) { build(:trainee, :provider_led_postgrad, course_allocation_subject: allocation_subject, start_academic_cycle: cycle) }

    it "keeps the rules in code, as before" do
      expect(described_class.funding_management_start_year(trainee.training_route)).to eq(2027)
      expect(funding_manager.funding_signed_off?).to be(true)
    end
  end

  describe "the year" do
    it "is open to EYTDA funding only, until it's signed off" do
      expect(cycle).to have_attributes(live?: true, eytda_only_funding_year?: true, locked_except_eytda?: true)

      cycle.update!(published: true)

      expect(cycle.reload.locked_except_eytda?).to be(false)
    end
  end
end
