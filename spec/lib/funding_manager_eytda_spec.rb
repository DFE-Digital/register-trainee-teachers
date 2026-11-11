# frozen_string_literal: true

require "rails_helper"

describe FundingManager do
  let(:route) { TRAINING_ROUTE_ENUMS[:early_years_teacher_degree_apprenticeship] }
  let(:current_cycle) { create(:academic_cycle, :current) }
  let(:start_cycle) { create(:academic_cycle, next_cycle: true) }
  let(:allocation_subject) { create(:allocation_subject) }
  let(:amounts) { { 1 => 16_500, 2 => 11_000, 3 => 11_000 } }
  let(:trainee) do
    build(:trainee, training_route: route, course_allocation_subject: allocation_subject, start_academic_cycle: start_cycle)
  end
  let(:funding_manager) { described_class.new(trainee) }

  before do
    current_cycle
    amounts.each do |training_year, amount|
      funding_method = create(:funding_method, training_route: route, funding_type: FUNDING_TYPE_ENUMS[:grant],
                                               academic_cycle: start_cycle, amount: amount, training_year: training_year)
      create(:funding_method_subject, funding_method:, allocation_subject:)
    end
  end

  it "is funded per training year" do
    expect(funding_manager.yearly_route?).to be(true)
  end

  it "lists the grant for each training year of the trainee's start year" do
    expect(funding_manager.grant_amounts_by_year).to eq(amounts)
  end

  context "when the trainee starts in a later year" do
    it "uses Year 1" do
      expect(funding_manager.training_year).to eq(1)
      expect(funding_manager.grant_amount).to eq(16_500)
      expect(funding_manager.can_apply_for_grant?).to be(true)
    end
  end

  context "when the HESA course year is sent" do
    before { trainee.build_hesa_trainee_detail(course_year: 3) }

    it "uses that training year" do
      expect(funding_manager.training_year).to eq(3)
      expect(funding_manager.grant_amount).to eq(11_000)
      expect(funding_manager.training_year_label).to eq(Funding::AmountMatrix.year_label(3, start_cycle.start_year))
    end
  end

  context "when the course year is not a training year" do
    before { trainee.build_hesa_trainee_detail(course_year: 7) }

    it "works out the training year from the start year" do
      expect(funding_manager.training_year).to eq(1)
      expect(funding_manager.grant_amount).to eq(16_500)
    end
  end

  context "when the trainee is in their second year" do
    let(:start_cycle) { create(:academic_cycle, previous_cycle: true) }

    it "works out the training year from the start year" do
      expect(funding_manager.training_year).to eq(2)
      expect(funding_manager.grant_amount).to eq(11_000)
    end
  end

  context "with a level 5 qualification (a 2-year course)" do
    before { trainee.level_five_qualification = true }

    let(:amounts) { { 1 => 16_500, 2 => 11_000, 3 => 9_000 } }

    it "funds Year 2 and Year 3, as they skip Year 1" do
      expect(funding_manager.training_years).to eq(2)
      expect(funding_manager.funded_years).to eq(2..3)
      expect(funding_manager.grant_amounts_by_year).to eq(2 => 11_000, 3 => 9_000)
      expect(funding_manager.shortened_by_level_five?).to be(true)
    end

    it "is in Year 2 in their first year, labelled with that academic year" do
      expect(funding_manager.training_year).to eq(2)
      expect(funding_manager.grant_amount).to eq(11_000)
      short = ->(year) { format("%02d", year % 100) }
      year = start_cycle.start_year
      expect(funding_manager.training_year_label).to eq("Year 2 (#{short.call(year)}/#{short.call(year + 1)})")
      expect(funding_manager.training_year_label(3)).to eq("Year 3 (#{short.call(year + 1)}/#{short.call(year + 2)})")
    end

    it "is in Year 3 for HESA course year 2" do
      trainee.build_hesa_trainee_detail(course_year: 2)

      expect(funding_manager.training_year).to eq(3)
      expect(funding_manager.grant_amount).to eq(9_000)
    end

    context "when the trainee is in their second year" do
      let(:start_cycle) { create(:academic_cycle, previous_cycle: true) }

      it "is in Year 3" do
        expect(funding_manager.training_year).to eq(3)
        expect(funding_manager.grant_amount).to eq(9_000)
      end
    end

    it "has no grant for a HESA course year after the course ends" do
      trainee.build_hesa_trainee_detail(course_year: 3)

      expect(funding_manager.training_year).to be_nil
      expect(funding_manager.grant_amount).to be_nil
    end
  end

  context "without a level 5 qualification (a 3-year course)" do
    before { trainee.level_five_qualification = false }

    it "funds Years 1 to 3" do
      expect(funding_manager.training_years).to eq(3)
      expect(funding_manager.funded_years).to eq(1..3)
      expect(funding_manager.training_year).to eq(1)
      expect(funding_manager.grant_amounts_by_year.keys).to eq([1, 2, 3])
      expect(funding_manager.shortened_by_level_five?).to be(false)
    end
  end

  context "for a route not funded per training year" do
    let(:trainee) { build(:trainee, training_route: :early_years_salaried, course_allocation_subject: allocation_subject, start_academic_cycle: start_cycle) }

    before do
      funding_method = create(:funding_method, training_route: :early_years_salaried, funding_type: FUNDING_TYPE_ENUMS[:grant],
                                               academic_cycle: start_cycle, amount: 16_535)
      create(:funding_method_subject, funding_method:, allocation_subject:)
    end

    it "has no training year and keeps the single grant" do
      expect(funding_manager.yearly_route?).to be(false)
      expect(funding_manager.training_year).to be_nil
      expect(funding_manager.grant_amounts_by_year).to eq({})
      expect(funding_manager.grant_amount).to eq(16_535)
    end
  end
end
