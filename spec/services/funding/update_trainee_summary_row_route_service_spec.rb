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

    let(:route_types) do
      {
        "School Direct salaried" => :school_direct_salaried,
        "Post graduate teaching apprenticeship" => :pg_teaching_apprenticeship,
        "EYITT Graduate entry" => :early_years_postgrad,
        "EYITT Graduate employment-based" => :early_years_salaried,
        "Provider-led" => :provider_led,
        "Undergraduate opt-in" => :opt_in_undergrad,
        "School Direct tuition fee" => :school_direct_tuition_fee,
      }
    end

    before do
      previous_academic_year_funding_trainee_summary.rows.each do |row|
        row.route_type = nil
        row.save!
      end

      current_academic_year_funding_trainee_summary.rows.each do |row|
        row.route_type = nil
        row.save!
      end
    end

    it "has the correct route types" do
      expect(subject::ROUTE_TYPES).to eq(route_types)
    end

    it "sets the route_type only for the current_academic_year" do
      subject.call

      previous_academic_year_funding_trainee_summary.rows.reload.each do |row|
        expect(row.route_type).to be_nil
      end

      current_academic_year_funding_trainee_summary.rows.reload.each do |row|
        expect(row.route_type).to eq(route_types[row.read_attribute(:route)].to_s)
      end
    end
  end
end
