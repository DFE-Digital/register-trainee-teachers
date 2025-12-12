# frozen_string_literal: true

require "rails_helper"

describe AcademicYearFilterOptions do
  let(:current_year_string) { "#{academic_cycle.label} (current year)" }

  let(:current_user) do
    double(training_partner?: false, provider?: true, organisation: trainee.provider, system_admin?: false)
  end

  let(:trainee) { create(:trainee, :trn_received, start_academic_cycle: academic_cycle) }
  let(:academic_cycle) { create(:academic_cycle, :current) }
  let(:trainee_start_date) { current_academic_cycle.start_date + 1.day }
  let(:cycle_context) { :start_year }

  before do
    allow(Trainees::SetAcademicCycles).to receive(:call)
  end

  context "non draft" do
    subject { described_class.new(user: current_user, draft: false).formatted_years(cycle_context) }

    context "when a trainee exists in the current academic cycle" do
      it "returns the year with current year label" do
        expect(subject).to contain_exactly(current_year_string)
      end
    end

    context "when a trainee exists in a non current academic cycle" do
      let(:academic_cycle) { create(:academic_cycle, cycle_year: 2020) }

      it "returns the year" do
        expect(subject).to contain_exactly("2020 to 2021")
      end
    end

    context "when trainees exist in multiple academic cycles" do
      before do
        create(:trainee,
               :trn_received,
               provider: trainee.provider,
               start_academic_cycle: create(:academic_cycle, cycle_year: 2020))
      end

      it "returns the years in reverse order" do
        expect(subject).to contain_exactly(current_year_string, "2020 to 2021")
      end
    end

    context "when there is only a draft trainee in an academic cycle" do
      let(:trainee) { create(:trainee, :draft, start_academic_cycle: academic_cycle) }

      it "the year is not returned" do
        expect(subject).to be_empty
      end
    end
  end

  context "draft" do
    let(:trainee) { create(:trainee, :draft, start_academic_cycle: academic_cycle) }

    subject { described_class.new(user: current_user, draft: true).formatted_years(cycle_context) }

    context "when there is a draft trainee in an academic cycle" do
      it "returns the year" do
        expect(subject).to contain_exactly(current_year_string)
      end
    end
  end

  context "trainee ending academic cycle is in the future" do
    let(:academic_cycle) { create(:academic_cycle, cycle_year: Time.zone.now.year + 2) }
    let(:trainee) { create(:trainee, :draft, end_academic_cycle: academic_cycle) }
    let(:cycle_context) { :end_year }

    subject { described_class.new(user: current_user, draft: true).formatted_years(cycle_context) }

    it "returns the future cycle" do
      expect(subject).to contain_exactly(academic_cycle.label)
    end
  end
end
