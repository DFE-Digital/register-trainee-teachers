# frozen_string_literal: true

require "rails_helper"

describe Api::V20270::HesaTraineeDetailAttributes::Rules::FundingMethod do
  subject(:result) { described_class.call(hesa_trainee_detail_attributes) }

  let(:academic_cycle) { create(:academic_cycle, cycle_year: 2027) }
  let(:allocation_subject) { create(:allocation_subject) }
  let(:school) { create(:school) }
  let(:training_route) { TRAINING_ROUTE_ENUMS[:provider_led_postgrad] }
  let(:degrees) { [] }
  let(:employing_school_id) { nil }
  let(:trainee_attributes) do
    double(
      training_route: training_route,
      course_subject_one: CourseSubjects::CHEMISTRY,
      course_allocation_subject_id: allocation_subject.id,
      degrees_attributes: degrees,
      employing_school_id: employing_school_id,
      trainee_start_date: nil,
      itt_start_date: "2027-10-01",
    )
  end
  let(:hesa_trainee_detail_attributes) do
    double(
      fund_code: Hesa::CodeSets::FundCodes::ELIGIBLE,
      funding_method: Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY,
      trainee_attributes: trainee_attributes,
    )
  end
  let(:chemistry_degree) { double(subject: DegreeSubjects::CHEMISTRY) }
  let(:history_degree) { double(subject: DegreeSubjects::HISTORY) }

  before do
    create(:subject_specialism, allocation_subject: allocation_subject, name: CourseSubjects::CHEMISTRY)
    create(:relevant_degree_subject, academic_cycle: academic_cycle, allocation_subject: allocation_subject, hecos_code: "100417")
  end

  def create_bursary(**conditions)
    funding_method = create(:funding_method, academic_cycle: academic_cycle, training_route: training_route, funding_type: FUNDING_TYPE_ENUMS[:bursary], **conditions)
    create(:funding_method_subject, funding_method:, allocation_subject:)
  end

  context "when the funding method has no conditions" do
    before { create_bursary }

    it { is_expected.to be_valid }

    context "with a relevant degree" do
      let(:degrees) { [chemistry_degree] }

      it { is_expected.to be_valid }
    end

    context "with an unrelated degree" do
      let(:degrees) { [history_degree] }

      it { is_expected.to be_valid }
    end

    context "with a school on the list" do
      let(:employing_school_id) { school.id }

      before { create(:funding_school_designation, academic_cycle:, school:) }

      it { is_expected.to be_valid }
    end

    context "with a school not on the list" do
      let(:employing_school_id) { school.id }

      it { is_expected.to be_valid }
    end
  end

  context "when the funding method is only for a relevant degree" do
    before { create_bursary(degree_relevance: "relevant") }

    context "with a relevant degree" do
      let(:degrees) { [chemistry_degree] }

      it { is_expected.to be_valid }
    end

    context "with an unrelated degree" do
      let(:degrees) { [history_degree] }

      it { is_expected.not_to be_valid }
    end

    context "with both a relevant and an unrelated degree" do
      let(:degrees) { [history_degree, chemistry_degree] }

      it { is_expected.to be_valid }
    end

    context "with a relevant degree at a school on the list" do
      let(:degrees) { [chemistry_degree] }
      let(:employing_school_id) { school.id }

      before { create(:funding_school_designation, academic_cycle:, school:) }

      it { is_expected.to be_valid }
    end

    context "without a degree" do
      it { is_expected.to be_valid }
    end

    context "with an undergraduate route" do
      let(:training_route) { TRAINING_ROUTE_ENUMS[:provider_led_undergrad] }
      let(:degrees) { [chemistry_degree] }

      it { is_expected.not_to be_valid }
    end
  end

  context "when the funding method is only for an unrelated degree" do
    before { create_bursary(degree_relevance: "unrelated") }

    context "with an unrelated degree" do
      let(:degrees) { [history_degree] }

      it { is_expected.to be_valid }
    end

    context "with a relevant degree" do
      let(:degrees) { [chemistry_degree] }

      it { is_expected.not_to be_valid }
    end
  end

  context "when the funding method is only for a disadvantaged school" do
    before { create_bursary(school_disadvantage: "disadvantaged") }

    context "with a school on the list" do
      let(:employing_school_id) { school.id }

      before { create(:funding_school_designation, academic_cycle:, school:) }

      it { is_expected.to be_valid }
    end

    context "with a relevant degree at a school on the list" do
      let(:degrees) { [chemistry_degree] }
      let(:employing_school_id) { school.id }

      before { create(:funding_school_designation, academic_cycle:, school:) }

      it { is_expected.to be_valid }
    end

    context "with a school not on the list" do
      let(:employing_school_id) { school.id }

      it { is_expected.not_to be_valid }
    end

    context "with a school on the list for a different academic year" do
      let(:employing_school_id) { school.id }

      before { create(:funding_school_designation, academic_cycle: create(:academic_cycle, cycle_year: 2028), school: school) }

      it { is_expected.not_to be_valid }
    end

    context "without a school" do
      it { is_expected.to be_valid }
    end
  end

  context "when the funding method is only for a non-disadvantaged school" do
    before { create_bursary(school_disadvantage: "non_disadvantaged") }

    context "with a school not on the list" do
      let(:employing_school_id) { school.id }

      it { is_expected.to be_valid }
    end

    context "with a school on the list" do
      let(:employing_school_id) { school.id }

      before { create(:funding_school_designation, academic_cycle:, school:) }

      it { is_expected.not_to be_valid }
    end
  end

  context "when there is no funding method" do
    it { is_expected.not_to be_valid }
  end
end
