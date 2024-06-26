# frozen_string_literal: true

require "rails_helper"
require "csv"

describe FindNewStarterTrainees do
  subject { described_class.new(DateTime.new(2022, 10, 12)).call }

  before do
    create(:academic_cycle)
    create(:academic_cycle, previous_cycle: true, id: 10)
    allow(Trainees::SetAcademicCycles).to receive(:call) # deactivate so it doesn't override factories
  end

  around do |example|
    Timecop.freeze(Time.zone.local(2022, 9, 3)) do
      example.run
    end
  end

  let(:valid_trainee) { create(:trainee, state: 1, itt_start_date: 2.months.ago, start_academic_cycle: AcademicCycle.current) }
  let(:valid_trainee_with_no_trainee_start_date) { create(:trainee, state: 1, trainee_start_date: nil, start_academic_cycle: AcademicCycle.current) }
  let(:valid_draft_trainee) { create(:trainee, state: 0, itt_start_date: 2.months.ago, start_academic_cycle: AcademicCycle.current) }
  let(:valid_trainee_from_previous_academic_cycle) { create(:trainee, state: 0, itt_start_date: 2.months.ago, start_academic_cycle_id: 10) }

  it "to contain non draft current academic cycle trainees starting before the census date" do
    expect(subject).to include(valid_trainee)
  end

  it "to contain non draft current academic cycle trainees with no trainee start date" do
    expect(subject).to include(valid_trainee_with_no_trainee_start_date)
  end

  it "to not contain draft trainees" do
    expect(subject).not_to include(valid_draft_trainee)
  end

  it "to not contain valid trainees starting in a previous academic cycle" do
    expect(subject).not_to include(valid_trainee_from_previous_academic_cycle)
  end

  context "when trainee came from HESA TRN data" do
    let!(:trainee) do
      create(
        :trainee,
        state: 1,
        itt_start_date: 2.months.ago,
        start_academic_cycle: AcademicCycle.current,
        record_source: Trainee::HESA_TRN_DATA_SOURCE,
      )
    end

    it { is_expected.to include(trainee) }
  end
end
