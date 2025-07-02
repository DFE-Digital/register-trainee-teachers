# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V20250Rc::TraineeFilterParamsAttributes do
  it { is_expected.to validate_inclusion_of(:has_trn).in_array([true, false]) }

  describe "since validation" do
    context "when in ISO 8601" do
      it "correctly formatted dates are valid" do
        %w[2024-03-15T12:15:37.879Z 12345 2024-01-01].each do |since|
          expect(described_class.new(since:).valid?).to be(true)
        end
      end
    end

    context "when not in ISO 8601" do
      it "is not valid" do
        expect(described_class.new(since: "01-01-2020").valid?).to be(false)
      end
    end

    context "when non dates" do
      it "non-dates are not valid and return an error message" do
        %w[2020-01-32 123 date].each do |since|
          filter_params = described_class.new(since:)
          expect(filter_params.valid?).to be(false)
          expect(filter_params.errors[:since]).to include("#{since} is not a valid date")
        end
      end
    end
  end

  describe "academic_cycle validation" do
    before { create(:academic_cycle, start_date: Date.new(2020, 8, 1)) }

    it "validates a known academic cycle" do
      expect(described_class.new(academic_cycle: "2020").valid?).to be(true)
    end

    it "rejects an unknown academic cycle and returns an error message" do
      filter_params = described_class.new(academic_cycle: "1066")
      expect(filter_params.valid?).to be(false)
      expect(filter_params.errors[:academic_cycle]).to include("1066 is not a valid academic cycle year")
    end
  end

  describe "status validation" do
    it "validates known statuses" do
      expect(described_class.new(status: "in_training").valid?).to be(true)
      expect(described_class.new(status: %w[in_training withdrawn]).valid?).to be(true)
    end

    it "validates status" do
      filter_params = described_class.new(status: "waiting_at_the_station")
      expect(filter_params.valid?).to be(false)
      expect(filter_params.errors[:status]).to include("waiting_at_the_station is not a valid status")
    end
  end
end
