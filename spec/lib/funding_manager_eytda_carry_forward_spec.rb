# frozen_string_literal: true

require "rails_helper"

# EYTDA amounts entered for a year apply to every later start year until newer
# amounts are added.
describe FundingManager do
  def cycle_for(year)
    AcademicCycle.for_year(year) || create(:academic_cycle, start_date: Date.new(year, 8, 1), end_date: Date.new(year + 1, 7, 31))
  end

  let(:route) { FundingManager::EYTDA_ROUTE }
  let(:allocation_subject) { create(:allocation_subject) }
  let(:start_cycle) { cycle_for(2027) }
  let(:trainee) { build(:trainee, training_route: route, course_allocation_subject: allocation_subject, start_academic_cycle: start_cycle) }
  let(:funding_manager) { described_class.new(trainee) }

  def add_eytda_amounts(cycle, amounts)
    amounts.each do |training_year, amount|
      funding_method = create(:funding_method, training_route: route, funding_type: FUNDING_TYPE_ENUMS[:grant], academic_cycle: cycle,
                                               amount: amount, training_year: training_year)
      create(:funding_method_subject, funding_method:, allocation_subject:)
    end
  end

  before do
    enable_features(:funding_eligibility_step)
    add_eytda_amounts(cycle_for(2026), 1 => 8_236, 2 => 8_236, 3 => 6_177)
  end

  it "uses the 2026 to 2027 amounts for a 2027 to 2028 starter" do
    expect(funding_manager.funding_cycle).to eq(cycle_for(2026))
    expect(funding_manager.funding_carried_forward?).to be(true)
    expect(funding_manager.grant_amounts_by_year).to eq(1 => 8_236, 2 => 8_236, 3 => 6_177)
  end

  it "labels the training years from the trainee's own start year" do
    expect(funding_manager.training_year_label(1)).to eq("Year 1 (27/28)")
  end

  it "uses a later year's amounts from that year on" do
    add_eytda_amounts(start_cycle, 1 => 9_000, 2 => 9_000, 3 => 7_000)

    expect(funding_manager.funding_cycle).to eq(start_cycle)
    expect(funding_manager.funding_carried_forward?).to be(false)
    expect(funding_manager.grant_amounts_by_year[1]).to eq(9_000)
  end

  it "keeps the earlier amounts for trainees starting before the later year" do
    add_eytda_amounts(cycle_for(2028), 1 => 9_000)

    expect(funding_manager.funding_cycle).to eq(cycle_for(2026))
  end

  it "has no carried-forward amounts before 2026 to 2027" do
    trainee.start_academic_cycle = cycle_for(2025)

    expect(described_class.new(trainee).funding_cycle).to eq(cycle_for(2025))
    expect(described_class.new(trainee).grant_amounts_by_year).to be_empty
  end

  it "takes sign-off from the year the amounts were entered for" do
    Timecop.travel(Date.new(2027, 10, 1)) do
      cycle_for(2026).update!(published: true)
      expect(described_class.new(trainee).funding_signed_off?).to be(true)

      cycle_for(2026).update!(published: false)
      expect(described_class.new(trainee).funding_signed_off?).to be(false)
    end
  end

  it "doesn't carry forward other routes' funding" do
    other = build(:trainee, :provider_led_postgrad, course_allocation_subject: allocation_subject, start_academic_cycle: start_cycle)

    expect(described_class.new(other).funding_cycle).to eq(start_cycle)
  end
end
