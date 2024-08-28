# frozen_string_literal: true

require "rails_helper"

RSpec.describe Funding::UpdateTraineeSummaryRowRouteService do
  subject { described_class }

  let(:training_routes) do
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

  describe "::TRAINING_ROUTES" do
    it "has the correct route types" do
      expect(subject::TRAINING_ROUTES).to eq(training_routes)
    end
  end

  describe "#call" do
    let(:previous_academic_year) { "2023/24" }

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
      )
    end

    before do
      previous_academic_year_funding_trainee_summary.rows.each do |row|
        row.training_route = nil
        row.save!
      end

      current_academic_year_funding_trainee_summary.rows.each do |row|
        row.training_route = nil
        row.route = " #{row.route} "
        row.save!
      end
    end

    it "sets the training_route only for the current_academic_year" do
      subject.call

      previous_academic_year_funding_trainee_summary.rows.reload.each do |row|
        expect(row.training_route).to be_nil
      end

      current_academic_year_funding_trainee_summary.rows.reload.each do |row|
        expect(row.training_route).to eq(training_routes[row.read_attribute(:route).strip].to_s)
      end
    end
  end
end
