# frozen_string_literal: true

require "rails_helper"

describe StartYearFilterOptions do
  let(:current_year_string) { "#{current_academic_cycle.start_year} to #{current_academic_cycle.start_year + 1} (current year)" }
  let(:current_user) do
    double(
      lead_school?: false, provider?: true, organisation: trainee.provider, system_admin?: false,
    )
  end
  let(:trainee) { create(:trainee, :trn_received, commencement_date: trainee_start_date) }
  let(:current_academic_cycle) { create(:academic_cycle, :current) }
  let(:trainee_start_date) { current_academic_cycle.start_date + 1.day }

  before { current_academic_cycle }

  context "non draft" do
    subject { described_class.render(user: current_user, draft: false) }

    context "when a trainee exists in the current academic cycle" do
      it "returns the year with current year label" do
        expect(subject).to match_array([current_year_string])
      end
    end

    context "when a trainee exists in a non current academic cycle" do
      let(:academic_cycle) { create(:academic_cycle, cycle_year: 2020) }
      let(:trainee_start_date) { academic_cycle.start_date + 1.day }

      before { trainee }

      it "returns the year" do
        expect(subject).to match_array(["2020 to 2021"])
      end
    end

    context "when trainees exist in multiple academic cycles" do
      let(:academic_cycle) { create(:academic_cycle, cycle_year: 2020) }
      let(:trainee_start_date) { academic_cycle.start_date + 1.day }
      let(:other_trainee) { create(:trainee, :trn_received, provider: trainee.provider, commencement_date: current_academic_cycle.start_date + 1.day) }

      before do
        trainee
        other_trainee
      end

      it "returns the years in reverse order" do
        expect(subject).to match_array(
          [
            current_year_string,
            "2020 to 2021",
          ],
        )
      end
    end

    context "when there is only a draft trainee in an academic cycle" do
      let(:trainee) { create(:trainee, :draft, commencement_date: trainee_start_date) }

      it "the year is not returned" do
        expect(subject).to be_empty
      end
    end
  end

  context "draft" do
    let(:trainee) { create(:trainee, :draft, commencement_date: trainee_start_date) }

    subject { described_class.render(user: current_user, draft: true) }

    context "when there is a draft trainee in an academic cycle" do
      it "returns the year" do
        expect(subject).to match_array(
          [
            current_year_string,
          ],
        )
      end
    end
  end
end
