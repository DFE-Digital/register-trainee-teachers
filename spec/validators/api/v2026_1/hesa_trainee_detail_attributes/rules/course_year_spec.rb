# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V20261::HesaTraineeDetailAttributes::Rules::CourseYear do
  subject(:result) { described_class.call(hesa_trainee_detail_attributes) }

  let(:trainee_attributes) { Api::V20261::TraineeAttributes.new(training_route:) }
  let(:hesa_trainee_detail_attributes) do
    Api::V20261::HesaTraineeDetailAttributes.new({ course_year:, trainee_attributes: }, record_source: "api")
  end

  context "when the route is the Early years teacher degree apprenticeship" do
    let(:training_route) { TRAINING_ROUTE_ENUMS[:early_years_teacher_degree_apprenticeship] }

    %w[1 2 3].each do |year|
      context "with course year #{year}" do
        let(:course_year) { year }

        it { expect(result.valid?).to be(true) }
      end
    end

    %w[0 4].each do |year|
      context "with course year #{year}" do
        let(:course_year) { year }

        it "is invalid" do
          expect(result.valid?).to be(false)
          expect(result.error_type).to eq(:training_year_invalid)
          expect(result.error_details).to eq(training_years: 3)
        end
      end
    end

    context "when the course year is blank" do
      let(:course_year) { nil }

      it { expect(result.valid?).to be(true) }
    end
  end

  context "when the route is not funded per training year" do
    let(:training_route) { TRAINING_ROUTE_ENUMS[:early_years_salaried] }
    let(:course_year) { "0" }

    it { expect(result.valid?).to be(true) }
  end
end
