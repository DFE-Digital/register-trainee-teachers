# frozen_string_literal: true

require "rails_helper"

RSpec.describe Funding::UpdateTraineeSummaryRowRouteService do
  subject { described_class }

  let(:training_routes) do
    {
      "School Direct salaried" => "school_direct_salaried",
      "Post graduate teaching apprenticeship" => "pg_teaching_apprenticeship",
      "EYITT Graduate entry" => "early_years_postgrad",
      "EYITT Graduate employment-based" => "early_years_salaried",
      "Provider-led" => {
        "PG" => "provider_led_postgrad",
        "UG" => "provider_led_undergrad",
      },
      "Undergraduate opt-in" => "opt_in_undergrad",
      "School Direct tuition fee" => "school_direct_tuition_fee",
      "Teacher degree apprenticeship" => "teacher_degree_apprenticeship",
    }
  end

  describe described_class::TrainingRouteMapper do
    subject { described_class }

    describe "::TRAINING_ROUTES" do
      it "has the correct route types" do
        expect(subject::TRAINING_ROUTES).to eq(training_routes)
      end
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

      current_academic_year_funding_trainee_summary.rows.first(3).each do |row|
        row.training_route = nil
        row.route = " #{row.route} "
        row.cohort_level = " #{row.cohort_level}"
        row.save!
      end

      current_academic_year_funding_trainee_summary.rows.last(2).each do |row|
        row.training_route = row.cohort_level = nil
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
        route                   = row.read_attribute(:route).strip
        cohort_level            = row.read_attribute(:cohort_level).to_s.strip
        expected_training_route = training_routes[route][cohort_level].presence || training_routes[route]

        expect(row.training_route).to eq(expected_training_route)
      end
    end
  end
end
