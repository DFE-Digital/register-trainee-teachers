# frozen_string_literal: true

require "rails_helper"

describe Api::TraineeFilterParams do
  describe "since validation" do
    describe "since data validation" do
      it "correctly formatted dates are valid" do
        expect(described_class.new(since: "2020-01-01").valid?).to be(true)
      end

      it "non-dates are not valid and return an error message" do
        filter_params = described_class.new(since: "2020-01-32")
        expect(filter_params.valid?).to be(false)
        expect(filter_params.errors[:since]).to include("2020-01-32 is not a valid date")
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
        expect(described_class.new(status: "trn_received").valid?).to be(true)
        expect(described_class.new(status: %w[trn_received withdrawn]).valid?).to be(true)
      end

      it "validates status" do
        filter_params = described_class.new(status: "waiting_at_the_station")
        expect(filter_params.valid?).to be(false)
        expect(filter_params.errors[:status]).to include("waiting_at_the_station is not a valid status")
      end
    end
  end
end
