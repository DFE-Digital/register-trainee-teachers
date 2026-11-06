# frozen_string_literal: true

require "rails_helper"

describe "example_data:demo_funding" do
  subject(:run_task) { Rake::Task["example_data:demo_funding"].execute }

  let(:cycle2026) { AcademicCycle.for_year(2026) || create(:academic_cycle, start_date: Date.new(2026, 8, 1), end_date: Date.new(2027, 7, 31)) }
  let(:cycle2027) { AcademicCycle.for_year(2027) || create(:academic_cycle, start_date: Date.new(2027, 8, 1), end_date: Date.new(2028, 7, 31)) }
  let(:eytda) { TRAINING_ROUTE_ENUMS[:early_years_teacher_degree_apprenticeship] }

  before do
    cycle2026
    cycle2027
    [AllocationSubjects::EARLY_YEARS_ITT, AllocationSubjects::CHEMISTRY, AllocationSubjects::PHYSICS, AllocationSubjects::MATHEMATICS].each do |name|
      AllocationSubject.find_by(name:) || create(:allocation_subject, name:)
    end
    create_list(:school, 3)
  end

  it "adds the 2026 to 2027 EYTDA grant, signed off" do
    run_task

    grants = cycle2026.funding_methods.where(training_route: eytda).order(:training_year)
    expect(grants.pluck(:training_year, :amount)).to eq([[1, 8_236], [2, 8_236], [3, 6_177]])
    expect(cycle2026.reload.published).to be(true)
  end

  it "adds 2027 to 2028 draft funding that depends on the degree or the school" do
    run_task

    expect(cycle2027.reload.published).to be(false)
    expect(cycle2027.funding_methods.count).to eq(14)
    expect(cycle2027.funding_methods.where(availability: :not_available).count).to eq(2)
    expect(cycle2027.funding_methods.where(school_disadvantage: :disadvantaged).pluck(:amount).uniq).to eq([29_000])
  end

  it "adds the relevant degree lists and the school list" do
    run_task

    chemistry = AllocationSubject.find_by(name: AllocationSubjects::CHEMISTRY)
    expect(RelevantDegreeMapping.where(academic_cycle: cycle2027, allocation_subject: chemistry).pluck(:hecos_code)).to include("100417")
    expect(FundingSchoolDesignation.where(academic_cycle: cycle2027).group(:designation).count).to eq("disadvantaged" => 2, "special" => 1)
  end

  it "can be run more than once" do
    Rake::Task["example_data:demo_funding"].execute
    expect { Rake::Task["example_data:demo_funding"].execute }.not_to change { [FundingMethod.count, RelevantDegreeMapping.count, FundingSchoolDesignation.count] }
  end
end
