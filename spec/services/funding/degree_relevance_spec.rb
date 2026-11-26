# frozen_string_literal: true

require "rails_helper"

describe Funding::DegreeRelevance do
  subject(:degree_relevance) { described_class.new(trainee, academic_cycle: cycle, allocation_subject: mathematics) }

  let(:cycle) { AcademicCycle.current || create(:academic_cycle, :current) }
  let(:mathematics) { create(:allocation_subject, name: AllocationSubjects::MATHEMATICS) }
  let(:mathematics_degree) { DfEReference::DegreesQuery::SUBJECTS.all.find { |s| s.name == "Mathematics" } }
  let(:astronomy_degree) { DfEReference::DegreesQuery::SUBJECTS.all.find { |s| s.name == "Astronomy" } }
  let(:route) { TRAINING_ROUTE_ENUMS[:provider_led_postgrad] }
  let(:trainee) { create(:trainee, training_route: route, course_allocation_subject: mathematics, start_academic_cycle: cycle) }

  before do
    create(:relevant_degree_subject, academic_cycle: cycle, allocation_subject: mathematics, hecos_code: mathematics_degree.hecos_code)
  end

  def add_degree(reference_subject)
    create(:degree, :uk_degree_with_details, trainee: trainee, subject_uuid: reference_subject.id, subject: reference_subject.name)
  end

  describe "#answer" do
    it "is unknown before a degree is added" do
      expect(degree_relevance.answer).to eq(:unknown)
    end

    it "is relevant when a degree HECoS is on the list" do
      add_degree(mathematics_degree)

      expect(degree_relevance.answer).to eq(:relevant)
    end

    it "is unrelated when no degree HECoS is on the list" do
      add_degree(astronomy_degree)

      expect(degree_relevance.answer).to eq(:unrelated)
    end

    it "is relevant when any degree is on the list" do
      add_degree(astronomy_degree)
      add_degree(mathematics_degree)

      expect(degree_relevance.answer).to eq(:relevant)
    end

    context "on an undergraduate route" do
      let(:route) { TRAINING_ROUTE_ENUMS[:provider_led_undergrad] }

      it "is not_applicable" do
        expect(degree_relevance.answer).to eq(:not_applicable)
      end
    end
  end

  describe "#matches?" do
    let(:relevant_method) { build(:funding_method, degree_relevance: :relevant) }
    let(:unrelated_method) { build(:funding_method, degree_relevance: :unrelated) }
    let(:unconditioned_method) { build(:funding_method, degree_relevance: nil) }

    it "matches unconditioned funding for everyone" do
      expect(degree_relevance.matches?(unconditioned_method)).to be(true)
    end

    it "matches either conditioned value while the degree is unknown" do
      expect(degree_relevance.matches?(relevant_method)).to be(true)
      expect(degree_relevance.matches?(unrelated_method)).to be(true)
    end

    it "matches only the relevant value for a relevant degree" do
      add_degree(mathematics_degree)

      expect(degree_relevance.matches?(relevant_method)).to be(true)
      expect(degree_relevance.matches?(unrelated_method)).to be(false)
    end

    it "matches only the unrelated value for an unrelated degree" do
      add_degree(astronomy_degree)

      expect(degree_relevance.matches?(relevant_method)).to be(false)
      expect(degree_relevance.matches?(unrelated_method)).to be(true)
    end
  end
end
