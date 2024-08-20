# frozen_string_literal: true

require "rails_helper"

RSpec.describe Funding::UpdateTraineeSummaryRowRouteService do
  subject { described_class }

  describe "#call" do
    let(:previous_academic_year) { "2023/2024" }
    let(:current_academic_year) { "2024/2025" }

    let!(:previous_academic_year_funding_trainee_summary) do
      create(
        :trainee_summary,
        :for_school,
        :with_bursary_and_scholarship_and_multiple_amounts,
        academic_year: previous_academic_year,
      )
    end

    let!(:current_academic_year_funding_trainee_summary) do
      create(
        :trainee_summary,
        :for_school,
        :with_bursary_and_scholarship_and_multiple_amounts,
        academic_year: current_academic_year,
      )
    end

    let(:mapping) do
      {
        "Early years graduate employment based" => :early_years_salaried,
        "Provider-led" => :provider_led,
        "School Direct tuition fee" => :school_direct_tuition_fee,
        "School Direct salaried" => :school_direct_salaried,
        "Assessment only" => :assessment_only,
        "Early years assessment only" => :early_years_assessment_only,
        "Early years" => :early_years,
        "International qualified teacher status (iQTS)" => :iqts,
        "Primary and secondary" => :provider_led_undergrad,
        "Teaching apprenticeship" => :pg_teaching_apprenticeship,
        "School direct" => :school_direct_salaried,
        "HPITT" => :hpitt_postgrad,
        "Opt-in" => :opt_in_undergrad,
      }
    end

    before do
      previous_academic_year_funding_trainee_summary.rows.each do |row|
        row.route = row.read_attribute(:route)
        row.route_type = nil
        row.save!
      end
    end

    it "has the correct mapping" do
      expect(subject::ROUTE_MAPPING).to eq(mapping)
    end

    it "sets the route_type only for the current_academic_year" do
      subject.call

      previous_academic_year_funding_trainee_summary.rows.reload.each do |row|
        expect(row.route_type).to be_nil
      end

      current_academic_year_funding_trainee_summary.rows.reload.each do |row|
        expect(row.route_type).to eq(mapping[row.route].to_s)
      end
    end
  end
end
