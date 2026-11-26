# frozen_string_literal: true

require "rails_helper"

module Funding
  describe View do
    let(:route) { TRAINING_ROUTE_ENUMS[:early_years_teacher_degree_apprenticeship] }
    let(:current_cycle) { create(:academic_cycle, :current) }
    let(:start_cycle) { create(:academic_cycle, next_cycle: true) }
    let(:allocation_subject) { create(:allocation_subject) }
    let(:amounts) { { 1 => 16_500, 2 => 11_000, 3 => 9_000 } }
    let(:level_five_qualification) { nil }
    let(:applying_for_grant) { true }
    let(:trainee) do
      create(:trainee, training_route: route, course_allocation_subject: allocation_subject,
                       itt_start_date: start_cycle.start_date + 10.days, trainee_start_date: start_cycle.start_date + 10.days,
                       level_five_qualification: level_five_qualification, applying_for_grant: applying_for_grant, training_initiative: ROUTE_INITIATIVES_ENUMS[:no_initiative])
    end

    before do
      current_cycle
      start_cycle
      amounts.each do |training_year, amount|
        funding_method = create(:funding_method, training_route: route, funding_type: FUNDING_TYPE_ENUMS[:grant],
                                                 academic_cycle: start_cycle, amount: amount, training_year: training_year)
        create(:funding_method_subject, funding_method:, allocation_subject:)
      end
      render_inline(View.new(data_model: trainee, editable: true))
    end

    def year_label(year, first_year: 1)
      Funding::AmountMatrix.year_label(year, start_cycle.start_year - first_year + 1)
    end

    it "has no training initiative row" do
      expect(rendered_content).not_to have_text("Training initiative")
    end

    it "shows the Employer Support Grant (ESG) for each funded year" do
      expect(rendered_content).to have_text("Employer Support Grant (ESG)")
      expect(rendered_content).to have_text("Estimated ESG amount:")
      expect(rendered_content).to have_text("#{year_label(1)}: £16,500")
      expect(rendered_content).to have_text("#{year_label(2)}: £11,000")
      expect(rendered_content).to have_text("#{year_label(3)}: £9,000")
      expect(rendered_content).not_to have_text("grant")
    end

    context "with Year 2 entry" do
      let(:level_five_qualification) { true }

      it "shows the ESG for Year 2 and Year 3 only" do
        expect(rendered_content).to have_text("#{year_label(2, first_year: 2)}: £11,000")
        expect(rendered_content).to have_text("#{year_label(3, first_year: 2)}: £9,000")
        expect(rendered_content).not_to have_text("Year 1")
      end
    end

    context "when not applying for the ESG" do
      let(:applying_for_grant) { false }

      it { expect(rendered_content).to have_text("Not ESG funded") }
    end
  end
end
