# frozen_string_literal: true

require "rails_helper"

describe SignOffPeriodService do
  describe ".call" do
    subject { described_class.call }

    context "during the census sign off period" do
      before do
        allow(Date).to receive(:today).and_return(Date.new(2023, 10, 15))
      end

      it "returns :census_period" do
        expect(subject).to eq(:census_period)
      end
    end

    context "during the performance profiles sign off period" do
      before do
        allow(Date).to receive(:today).and_return(Date.new(2023, 1, 15))
      end

      it "returns :performance_period" do
        expect(subject).to eq(:performance_period)
      end
    end

    context "outside of sign off periods" do
      before do
        allow(Date).to receive(:today).and_return(Date.new(2023, 6, 15))
      end

      it "returns :outside_period" do
        expect(subject).to eq(:outside_period)
      end
    end
  end
end
