# frozen_string_literal: true

require "rails_helper"

describe "example_data:demo_funding" do
  subject(:run_task) { Rake::Task["example_data:demo_funding"].execute }

  let!(:cycle) { AcademicCycle.for_year(2027) || create(:academic_cycle, start_date: Date.new(2027, 8, 1), end_date: Date.new(2028, 7, 31)) }

  before do
    [AllocationSubjects::CHEMISTRY, AllocationSubjects::MATHEMATICS].each do |name|
      AllocationSubject.find_by(name:) || create(:allocation_subject, name:)
    end
    create_list(:school, 3)
  end

  it "adds degree-split bursaries and school-split grants" do
    run_task

    chemistry = AllocationSubject.find_by!(name: AllocationSubjects::CHEMISTRY)
    maths = AllocationSubject.find_by!(name: AllocationSubjects::MATHEMATICS)

    expect(
      cycle.funding_methods.joins(:allocation_subjects)
           .where(allocation_subjects: { id: chemistry.id }, degree_relevance: :relevant)
           .pluck(:amount).uniq,
    ).to eq([29_000])
    expect(
      cycle.funding_methods.joins(:allocation_subjects)
           .where(allocation_subjects: { id: maths.id }, school_disadvantage: :disadvantaged)
           .pluck(:amount).uniq,
    ).to eq([29_000])
  end

  it "adds relevant degree and school designation lists" do
    run_task

    chemistry = AllocationSubject.find_by!(name: AllocationSubjects::CHEMISTRY)
    expect(RelevantDegreeSubject.where(academic_cycle: cycle, allocation_subject: chemistry).pluck(:hecos_code))
      .to include("100417", "101050")
    expect(FundingSchoolDesignation.where(academic_cycle: cycle).group(:designation).count)
      .to eq("disadvantaged" => 2, "special" => 1)
  end

  it "can be run more than once" do
    Rake::Task["example_data:demo_funding"].execute

    expect { Rake::Task["example_data:demo_funding"].execute }
      .not_to change { [FundingMethod.count, RelevantDegreeSubject.count, FundingSchoolDesignation.count] }
  end
end
