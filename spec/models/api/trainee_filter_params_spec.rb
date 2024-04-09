# frozen_string_literal: true

require "rails_helper"

describe Api::TraineeFilterParams do
  describe "since validation" do
    it "validates since date" do
      expect(described_class.new(since: "2020-01-01").valid?).to be(true)
      expect(described_class.new(since: "2020-01-32").valid?).to be(false)
    end

    it "validates academic_cycle" do
      create(:academic_cycle, start_date: Date.new(2020, 8, 1))
      expect(described_class.new(academic_cycle: "2020").valid?).to be(true)
      expect(described_class.new(academic_cycle: "1066").valid?).to be(false)
    end

    it "validates status" do
      expect(described_class.new(status: "trn_received").valid?).to be(true)
      expect(described_class.new(status: %w[trn_received withdrawn]).valid?).to be(true)
      expect(described_class.new(status: "waiting_at_the_station").valid?).to be(false)
      expect(described_class.new(status: %w[eating_breakfast awarded]).valid?).to be(false)
    end
  end
end
