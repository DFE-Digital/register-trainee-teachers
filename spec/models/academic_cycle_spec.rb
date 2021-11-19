# frozen_string_literal: true

require "rails_helper"

describe AcademicCycle, type: :model do
  subject { build(:academic_cycle) }

  it { is_expected.to be_valid }

  describe "validations" do
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }

    context "dates" do
      context "when invalid values are given" do
        subject { build(:academic_cycle, start_date: "assasd") }

        it { is_expected.not_to be_valid }
      end

      context "when start date is after end date" do
        subject { build(:academic_cycle, start_date: Time.zone.today, end_date: Time.zone.yesterday) }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
